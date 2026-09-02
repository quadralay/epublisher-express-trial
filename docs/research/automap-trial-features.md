# AutoMap Features and Workflows for a Trial Experience

**Research question:** What features and workflows do WebWorks AutoMap and AutoMap Administrator offer that a trial user could realistically exercise during an evaluation?

**Date:** 2026-08-21

> This is the first research note in this repo. `docs/` previously held `agents/`, `brainstorms/`, `plans/`, and `prompts/`; `docs/research/` is introduced here, mirroring the `docs/research/` convention already used in the dev repo (`trunk: docs/research/`).

**Sources cited below:**

- `epublisher-docs:` = `C:\Projects\epublisher-docs` (authoritative end-user help source)
- `trunk:` = `C:\Repo\ePublisher_debug\trunk` (dev repo)
- `skill:` = webworks-agent-skills 3.9.2 `automap` skill (`C:\Users\mcdow\.claude\plugins\cache\webworks-agent-skills\webworks-agent-skills\3.9.2\skills\automap\`) — curated secondary source, cross-checked against the two repos where noted
- `this repo:` = `C:\Projects\epublisher-express-trial`

---

## 1. What AutoMap is and how it relates to Express/Designer

### The role it plays

AutoMap is the automation component of the ePublisher platform: it schedules and batch-runs the same content transformation that Express/Designer perform interactively, and integrates that with version control, content management, deployment, and notification (`epublisher-docs: legacy/epublisher-interface/automating-projects.md`, "What Is ePublisher AutoMap?" and "Benefits of Using ePublisher AutoMap"). The platform's role model: Designers make Stationery in Designer, writers generate in Express, and "ePublisher AutoMap can automatically generate and deploy online content using the Stationery created by a Stationery designer and source documents created by writers" (`epublisher-docs: legacy/epublisher-interface/exploring-epublisher-pro-express-automap.md`, "Understanding the ePublisher Workflow").

**Installation dependency that matters for a trial:** AutoMap requires ePublisher Express on the same computer, installed first. It can live on its own build machine or alongside a writer/designer install (`epublisher-docs: legacy/welcome-to-epublisher/planning-and-installing.md`, lines 30, 305–321). The Express trial guide already tells evaluators AutoMap "works with your existing Express installation" (`this repo: latest/online-trial-guides/express-trial/express-trial-guide.md`, "Automate with AutoMap").

### Two executables

AutoMap ships two executables in `C:\Program Files\WebWorks\ePublisher\<version>\ePublisher AutoMap\` (`epublisher-docs: aux-knowledge/_source/aux-automap-cli-vs-administrator.md`):

| Executable | What it is |
|---|---|
| `WebWorks.Automap.exe` | Headless CLI. Accepts `.wep`/`.wrp` projects, `.waj` jobs, and (2026.1) `.wacj` composition jobs; text output, exit codes 0/1. |
| `WebWorks.Automap.Administrator.exe` | The GUI ("AutoMap Administrator" / the "console"). Creates, edits, schedules, runs, and monitors jobs. |

A third binary, `WebWorks.AutoMap.exe` at the ePublisher *root* (not the version folder), is the version-independent launcher that Windows scheduled tasks actually invoke, so schedules survive upgrades (`trunk: docs/guides/automap-job-execution-and-logging.md`, "The execution pipeline" and "The launcher").

### Jobs and job files (.waj)

A **job** is "a set of tasks that ePublisher AutoMap can perform based on a Stationery or a project" — run immediately or on a schedule. Job files are proprietary XML with a `.waj` extension, stored one-folder-per-job under `Documents\WebWorks ePublisher AutoMap\Jobs\<name>\<name>.waj` (`epublisher-docs: legacy/epublisher-interface/automating-projects.md`, "Working with Jobs" and "Job Folder"; `trunk: docs/guides/automap-job-execution-and-logging.md`, "Jobs and the Jobs folder"). There is no import step: the Administrator scans the Jobs folder live, so a job restored from version control or written by hand appears as soon as its file lands there (`epublisher-docs: automating-projects.md`, "How ePublisher AutoMap Finds Your Jobs").

A job file contains (`skill: references/job-file-guide.md`, "XML Structure" and "Element Reference"; corroborated by `epublisher-docs: automating-projects.md`):

- `<Project path="..."/>` — the **origin** (Stationery `.wxsp`, or a `.wep`/`.wrp` project; 2026.1 adds `useAsStationery="True"`)
- `<Files>` — document groups and source documents (paths relative to the job file)
- `<Targets>` — targets with `build="True|False"`, `cleanOutput`, a named `destination`, and per-target overrides for **Conditions**, **Variables**, and **Settings**
- Optional `<MergeSettings>` per target — multivolume/merged TOC
- Optional `<Options skipReports verboseLogging>` (2026.1) — build options that travel with the job
- Optional inline `<DeploySettings>` destination definitions (2026.1; Folder and Amazon S3 only, never credentials)
- Pre/post-build scripts at job, target, and document-group level

### The three origin modes

Every job names exactly one origin, and the origin decides what a run does (`epublisher-docs: automating-projects.md`, "Choosing an Origin for a Job"; `skill: references/job-file-guide.md`, "Job Origin Modes"):

| Origin | Behavior | Output lands in |
|---|---|---|
| Stationery (`.wxsp`) | Stages a fresh project from the Stationery, injects the job's documents and target overrides, builds | Staging folder (`Documents\WebWorks ePublisher AutoMap\Staging\<JobName>\Output\<Target>\`) |
| Project built in place (`.wep`/`.wrp`) | Builds the project as it sits, using the project's own documents; the job's document list is ignored; synchronizes with the project's Stationery first | The project's own `Output\` folder |
| Project used as Stationery (`.wep`/`.wrp` + `useAsStationery="True"`, 2026.1) | Treats the live project like Stationery: fresh staged project, job's documents, origin never modified | Staging folder |

### The CLI

`WebWorks.Automap.exe` runs a job, a project, or a composition job. Documented options (`epublisher-docs: automating-projects.md`, "CLI Syntax and Reference"):

- `-c/--clean` (regenerate all), `-n/--nodeploy`, `-l/--cleandeploy`, `-d/--deployfolder <dir>`
- `-t/--target=<t1>,<t2>` (project default: all targets; job default: the `build="True"` set)
- `-u/--update` (scan for styles/conditions/variables/xrefs and save the Express project), `-j/--justupdate` (scan and save without building)
- `-f/--nonotify`, `-s/--stagingdir <dir>` (job files only)
- 2026.1: `-q/--quiet`, `--skip-reports`, `--deployscope=everything|groups|shell`, `--deploysettings=<file>`, `--destination=<name>`, `--dryrun` (rehearse deployment; S3 prints would-be operations, other transports skip deploying)

Exit contract: 0 = success, nonzero = errors reported; a scheduled task surfaces this as `Last Run Result` `0x0`/`0x1` (`trunk: docs/guides/automap-job-execution-and-logging.md`, "The exit-code contract").

### How this differs from clicking Generate in Express/Designer

- **Headless and schedulable.** No GUI, no open project; runs from the command line, Task Scheduler, or CI (`epublisher-docs: automating-projects.md`; `epublisher-docs: aux-knowledge/_source/aux-automap-cli-vs-administrator.md`).
- **Stationery-direct.** A Stationery-based job builds straight from a `.wxsp` plus a document list — no hand-created Express project needed; AutoMap stages one per run (`epublisher-docs: automating-projects.md`, "Preparing Projects, Stationery, and Source Files").
- **Per-job/per-target overrides without touching the project.** Conditions, variables, and format settings can differ per target inside one job — e.g., two targets from the same Stationery with different audiences (`epublisher-docs: automating-projects.md`, "Creating a Stationery-Based Job", step 11).
- **Hooks.** Pre/post-build scripts at job, target, and document-group level (batch-file semantics, with scripting variables such as `${ProjectDir}`, `${DeployFolder}`, `${ErrorCount}`) — Express has nothing comparable (`epublisher-docs: automating-projects.md`, "Using Scripts for Additional Custom Processing").
- **Deployment and notification built into the run.** Deploys to named destinations automatically and can email success/failure with the log attached (`epublisher-docs: automating-projects.md`, "Defining Output Destinations", "Defining Email Notifications").
- **Synchronization discipline.** A project-based job re-synchronizes with the Stationery before generating, so scheduled output never drifts from the current design (`epublisher-docs: automating-projects.md`, "Preparing Projects...").

---

## 2. The AutoMap Administrator UI

Concrete surfaces a trial user would touch, in the order they would meet them.

### Main window

A job list; each row is one job, with distinct icons for project-based vs Stationery-based jobs (a project *used as* Stationery shows the Stationery icon). All **Job** menu commands act on the selected row and are also on the right-click menu: **Edit, Rename, Duplicate, Schedule Job, Run, Stop, Delete, View Log, Explore Output, Preview Output in Browser** (`epublisher-docs: automating-projects.md`, "Working with Jobs", "How ePublisher AutoMap Finds Your Jobs", "Previewing Output in a Browser"). The list live-updates as job folders appear (`trunk: docs/guides/automap-job-execution-and-logging.md`).

### New Job wizard (File > New Job)

Three intents (`epublisher-docs: automating-projects.md`, "Creating a Project-Based Job", "Creating a Stationery-Based Job", "Creating a Composition Job"):

1. **Automate an existing project** — pick a `.wep`/`.wrp`; name the job; optional pre/post-build scripts; **Target Selection** window (Build checkboxes per target); done. Deployment comes from the project's own target settings.
2. **Create a new publishing job** — pick a `.wxsp` Stationery *or* a `.wep`/`.wrp` to use as Stationery; name the job; optional scripts; **Documents** window (New Group, Add Document, or a per-group retrieval script); **Target Selection**; **Target Configuration** window with per-target tabs (conditions, variables, settings; deployment on the Info tab); Finish.
3. **Compose published parcels into a website (Composition Job)** (2026.1) — opens the Composition Job window: members grid (Role = Shell/Parcel/Infer, Build checkbox per member), **Output target** combo, **Deployment** area (destination defined in the job, or one picked from Deploy Destinations), **Merge Settings** area (Automatic, or Custom with Add Group / Add Container / reorder).

Finishing a new publishing job drops straight into the Windows Scheduler prompt (cancelable) (`epublisher-docs: automating-projects.md`, "Scheduling Jobs with Windows Scheduler").

### Edit Job window

The wizard pages reappear as tabs. Notable tabs (`epublisher-docs: automating-projects.md`, "Editing an Existing Job", "Setting Build Options for a Job", "Defining Output Destinations Inside a Job"):

- **Job Info** — name, origin, scripts, and (2026.1) **Build options**: *Skip reports* and *Verbose logging*, stored in the `.waj` so they apply on schedules and bare CLI runs alike (they OR-combine with `--skip-reports`/`-q`).
- **Target Configuration** — per-target conditions/variables/settings overrides; **Deploy to** list on the Info tab. Destination names that don't resolve locally show as `MyDestination (not defined on this computer)` but are preserved on save.
- **Job Deploy Destinations** (2026.1) — Folder / Amazon S3 destination *definitions* carried inside the job file (no credentials allowed), which win over same-named machine destinations at run time.

### Preferences (Edit > Preferences)

- **General tab** — Job Folder, Staging Folder, User Formats Folder locations; *Always scan for variables and conditions* (off by default; a **Scan Documents** button exists on the condition/variable windows); *Delete temporary files after generating* (off by default — staged projects persist for inspection); console language (English, German, French, Japanese) (`epublisher-docs: automating-projects.md`, "Setting ePublisher AutoMap Preferences" through "Selecting Console Language").
- **File Mappings tab** — map file extensions to source adapters; only adapters licensed by the Contract ID are listed (`epublisher-docs: automating-projects.md`, "Defining File Mappings").
- **Notification tab** — enable email notification, addresses, mail server, attach-log option (`epublisher-docs: automating-projects.md`, "Defining Email Notifications").

### Deploy Destinations editor (Edit > Deploy Destinations...)

Create/edit named output destinations without opening a job: **Folder** (local or UNC path) and **Amazon S3** types offered from this entry point. One shared per-Windows-user list serves Express, Designer, and AutoMap (`epublisher-docs: automating-projects.md`, "Defining Output Destinations"; `epublisher-docs: legacy/epublisher-interface/exploring-epublisher-pro-express-automap.md`, "Understanding the Deploy Destinations Editor"). Opened from a specific target's settings, additional format-supported deployment types appear (`epublisher-docs: legacy/epublisher-interface/producing-output-based-on-stationery.md`, line 1690).

### Scheduling

**Job > Schedule Job** opens the Windows Task Scheduler editor (triggers, run-as account; "Run whether user is logged on or not" requires the Windows password). The task is named `waj <job name>` and its action is the version-independent launcher, so schedules survive upgrades; the running process shows in Task Manager as **WebWorks ePublisher AutoMap Launcher**; `Last Run Result` `0x0`/`0x1` tells success/errors without opening the log (`epublisher-docs: automating-projects.md`, "Scheduling Jobs with Windows Scheduler", "How a Scheduled Job Reports Its Result"; `trunk: docs/guides/automap-job-execution-and-logging.md`, "Scheduled tasks").

Restricted environments: `WebWorks.Automap.Administrator.restricted.bat` starts the console without elevation — jobs can be created and configured but **not launched or scheduled** (`epublisher-docs: automating-projects.md`, "To start ePublisher AutoMap without administrative privileges").

### Logs and output inspection

- **View Log** — per-job log (`<name>-log.txt`, last run only), with `[WARN]`/`[ERROR]` markers (localized on non-English consoles) and a closing tally that matches the marked lines (`epublisher-docs: automating-projects.md`, "Viewing a Job Log File", "Finding Warnings and Errors in a Log"; log architecture in `trunk: docs/guides/automap-job-execution-and-logging.md`).
- **Explore Output** — opens the deployed *files* (folder or S3 console); **Preview Output in Browser** (2026.1) — opens the deployed *site*, per deploying target (`epublisher-docs: automating-projects.md`, "Previewing Output in a Browser").
- A running job opens a console window showing the log as it generates; **Stop** cancels it (`epublisher-docs: automating-projects.md`, "Working with Jobs", "Canceling a Job").

### Script editor

Opened from any **Edit Script** button: a text area plus a **Script Variables** pane (double-click to insert `${JobDir}`, `${TargetName}`, `${DeployFolder}`, `${ErrorCount}`, etc.). Scripts are treated as DOS batch files and can call out to anything (`epublisher-docs: automating-projects.md`, "Opening and Using the Script Editor", "Scripting Variables").

---

## 3. What a LOCAL trial can demonstrate

### What actually exists in the trial materials (this repo)

- **Express trial project**: `latest/local-trial-projects/ePublisher Express Projects/ePublisher Express Trial Project/ePublisher Express Trial Project.wrp` — two targets, **Web Help** (WebWorks Reverb 2.0) and **PDF** (PDF - XSL-FO), one group "Help", Markdown++ source `Source Docs/quantum-sync.md` (which composes `topics/*.md` via includes). Its `<Origin>` points relatively at the shipped Stationery (`this repo:` the `.wrp` file, lines 2–16).
- **Express trial Stationery**: `latest/local-trial-projects/ePublisher Stationery/ePublisher Express Trial Stationery/ePublisher Express Trial Stationery.wxsp` — same two targets. **This is the load-bearing asset for AutoMap:** a real `.wxsp` a Stationery-based job can name as its origin.
- **Designer trial project**: `latest/local-trial-projects/ePublisher Designer Projects/ePublisher Designer Trial/ePublisher Designer Trial.wep` with its own Markdown++ topic set.
- The repo already contains working `.waj` examples used to publish the guides themselves (`this repo: automap-jobs/trial-express.waj`, `trial-designer.waj`) — structurally a perfect template (Stationery origin, one group, one Reverb target, per-target condition/variable overrides, MergeSettings), though they point at an absolute Stationery path on the maintainer's machine and would need rewriting against the trial Stationery.

### Demonstrable on one machine, no infrastructure

Everything below needs only Windows, an Express + AutoMap install, and the trial files:

1. **Headless CLI build of the trial project.** `WebWorks.Automap.exe -t "Web Help" "...\ePublisher Express Trial Project.wrp"` — the exact "same project, no GUI" moment. Also `-c`, `-n`, and `-t "Web Help,PDF"` for both targets (`epublisher-docs: automating-projects.md`, "CLI Examples"; the CLI accepts `.wrp` directly).
2. **Project-based job in the Administrator.** New Job > Automate an existing project > pick the trial `.wrp`; Target Selection; Run; View Log. Output lands in the project's own `Output\` folder — the same place Express put it (`epublisher-docs: automating-projects.md`, "Creating a Project-Based Job").
3. **Stationery-based job.** New Job > Create a new publishing job > pick the trial `.wxsp`; add `quantum-sync.md` to a group; enable Web Help and PDF; then **override a variable or condition per target** in Target Configuration — the clearest "one Stationery, many publications" demo. Point out that output lands in the **Staging Folder**, not next to the job (`epublisher-docs: automating-projects.md`, "Creating a Stationery-Based Job"; `skill: references/job-file-guide.md`, "Output Location (Staging Folder)").
4. **Run / Stop / View Log / Duplicate / Rename** — all local Job-menu operations (`epublisher-docs: automating-projects.md`).
5. **Scheduling.** Schedule the job for a few minutes out via the built-in Windows Task Scheduler integration; watch `Last Run Result` report `0x0`. Needs the user's Windows password for "run whether logged on or not", and cannot be shown in a restricted (non-elevated) session (`epublisher-docs: automating-projects.md`, "Scheduling Jobs with Windows Scheduler", restricted-bat note).
6. **Folder deploy destination.** Edit > Deploy Destinations... > Add Folder (e.g., `C:\helpdocs`); assign it to the target; run; then **Explore Output** and **Preview Output in Browser** open the deployed site from that folder (`epublisher-docs: automating-projects.md`, "Defining Output Destinations", "Previewing Output in a Browser").
7. **Pre/post-build scripts.** The documented time/date echo and mini-report examples run entirely locally and show the scripting-variable machinery (`epublisher-docs: automating-projects.md`, "Show Time and Date Example", "Using Scripting Variables Example").
8. **Job build options** (2026.1). Toggle Skip reports / Verbose logging on the Job Info tab and show the effect on build time and log detail (`epublisher-docs: automating-projects.md`, "Setting Build Options for a Job").
9. **Hand-authored/drop-in job files.** Copy a `.waj` folder into the Jobs folder and watch it appear — the bridge to "check your job into git" CI storytelling (`epublisher-docs: automating-projects.md`, "How ePublisher AutoMap Finds Your Jobs").
10. **Project-as-Stationery** (2026.1). Create a publishing job whose origin is the Designer trial `.wep` with the job's own document list — demonstrates skipping "Save As Stationery" (`epublisher-docs: automating-projects.md`, "Using an ePublisher Project as Stationery").

Markdown++ sources need none of the DCOM/Word configuration that Word inputs require, which keeps the local story clean (`epublisher-docs: legacy/welcome-to-epublisher/planning-and-installing.md`, "Configuring AutoMap for Microsoft Source Document Inputs" — explicitly a Word-input concern).

### Mention but don't demo

| Capability | Why not locally demonstrable in a trial |
|---|---|
| VCS/CMS retrieval scripts (CVS, Git, Subversion, Perforce, Vasont, SDL LiveContent...) | Needs a repository/CMS server and per-environment script editing; the shipped `getfilesaction_cvs.vbs` is explicitly a starting point, not runnable as-is (`epublisher-docs: automating-projects.md`, "Version Control System (VCS) Integration", "CVS Version Control Checkout Example") |
| Amazon S3 / CloudFront destinations, `--deploysettings`, `--dryrun` against S3 | Needs an AWS account, bucket, and a credential profile on the machine (`epublisher-docs: automating-projects.md`, "Defining Output Destinations" note; `epublisher-docs: producing-output-based-on-stationery.md`, "Amazon S3" destination) |
| Email notifications | Needs a reachable mail server (`epublisher-docs: automating-projects.md`, "Defining Email Notifications") |
| Composition jobs / federated parcels (`.wacj`) | Technically possible against a local Folder destination, but presupposes multiple independently deployed Reverb 2.0 parcel jobs plus shell/parcel deploy scopes — a multi-team scenario, disproportionate for a 2-step trial (`epublisher-docs: automating-projects.md`, "Creating a Composition Job"; `trunk: docs/guides/federated-parcel-composition.md` exists for depth) |
| Multi-writer/build-server story (destinations resolving per user/machine, `--destination` redirection) | The concepts demo fine verbally, but the failure modes only appear across machines/accounts (`epublisher-docs: automating-projects.md`, "Destinations That Are Not Defined on This Computer") |

---

## 4. Licensing and trial constraints

- **Contract IDs, not license keys.** All components license through a Contract ID; entering it (Help > License Keys) enables components and input-format adapters per the contract. Activation codes refresh automatically from the licensing server over the Internet; offline Contract IDs exist for disconnected environments (`epublisher-docs: legacy/welcome-to-epublisher/planning-and-installing.md`, "Working with Contract IDs", "Viewing Licensing...", "Managing Licensing in Environments without Internet Connectivity").
- **Evaluation Contract IDs are a documented, first-class path:** "If you are evaluating ePublisher, the WebWorks customer service team will send you an email that contains a Contract ID you can use when you install an evaluation copy of ePublisher" (`epublisher-docs: planning-and-installing.md`, "Obtaining Contract IDs"). WebWorks generates a Contract ID "when you purchase ePublisher or request an evaluation copy" (`ibid.`, "Working with Contract IDs").
- **Licensing is by component and input format.** Express, Designer, and AutoMap are separately licensed components; adapters (FrameMaker, Word, DITA...) are enabled per contract — the AutoMap File Mappings tab lists only adapters the Contract ID licenses (`epublisher-docs: planning-and-installing.md`, "Licensing Considerations"; `epublisher-docs: automating-projects.md`, "Defining File Mappings" note).
- **AutoMap's commercial terms differ from Express/Designer:** the EULA note says AutoMap "licensing terms can vary based on whether ePublisher AutoMap was purchased on a per writer or per server basis, or in conjunction with a Content Management System" (`epublisher-docs: planning-and-installing.md`, "Deactivating Licensing" note).
- **AutoMap enforces licensing itself.** The CLI performs a `RefreshLicenseKeys()` operation against the license payload on startup (serialized across parallel instances via a named wait handle) — evidence that AutoMap is license-gated like the GUI products, not a free companion tool (`trunk: docs/research/automap-blocking-mechanisms.md`, section 3).
- **An evaluation-detection hook exists, but no documented always-on watermark.** The adapter XSLT extension `wwadapter:TemporaryLicense($toolAdapterName)` returns true under a temporary license, and the documented example renders an `Evaluation Version` notice into output (`trunk: docs/reference/xslt-extensions/adapter.md`, "TemporaryLicense"; mirrored in `epublisher-docs: legacy/advanced-customizations/xslt-extensions/adapter.md`). Neither repo documents a built-in trial watermark, page limit, target limit, or output cap for evaluation builds — the mechanism is available to format transforms, not (per the docs) imposed by the engine.
- **No AutoMap-specific "trial mode" is documented anywhere.** Nothing in either repo describes AutoMap behaving differently under an evaluation Contract ID (no job-count limits, no scheduling restrictions, no CLI restrictions).
- **Installer/download practicalities:** evaluation users get a download link by email; links expire in one to two weeks (`epublisher-docs: planning-and-installing.md`, "Downloading ePublisher Installers"). Express must be installed before AutoMap (`ibid.`, install-order note, line 321).

---

## Gaps and open questions

1. **Does the standard trial Contract ID enable the AutoMap component?** The docs establish evaluation Contract IDs and per-component licensing, but nowhere state whether the trial contract WebWorks issues to self-serve evaluators includes AutoMap, or whether AutoMap evaluation requires a sales conversation (its commercial terms are per-writer/per-server/CMS). This is the single biggest unknown for designing an AutoMap trial guide. *(Product owner / customer service question.)*
2. **Is trial output watermarked in practice?** `wwadapter:TemporaryLicense` exists and the doc example shows an eval notice, but I did not find (and did not exhaustively search format transforms in `trunk` for) any shipped format that calls it. Whether current Reverb 2.0 / PDF output carries an evaluation mark is unverified.
3. **Mild contradiction on hand-editing job files.** `epublisher-docs: automating-projects.md` says "ePublisher AutoMap maintains the job files. Do not edit these files" (Job Folder section), while the same document's "How ePublisher AutoMap Finds Your Jobs" embraces jobs "wrote by hand," and the skill/dev docs treat hand-authored `.waj` files as a primary workflow. A trial guide should pick one register (probably: GUI creates, git carries, hand-editing is an advanced move).
4. **Scheduling on locked-down trial machines.** Scheduling requires Task Scheduler rights and the user's Windows password; the restricted-mode launcher can configure but not run or schedule jobs. A trial guide needs a fallback path (Run instead of Schedule) for corporate-locked laptops.
5. **This repo's `automap-jobs/*.waj` are not trial collateral.** They reference an absolute Stationery path on the maintainer's machine (`C:\Projects\epublisher-docs-publish\...`) and use the pre-release `deployTarget` attribute spelling (`skill: references/job-file-guide.md` notes `destination` is the current spelling, `deployTarget` read "for one release"). If a trial guide ships a sample `.waj`, it should be authored fresh against `ePublisher Express Trial Stationery.wxsp` with relative paths.
6. **Version floor.** The clean UI story (composition jobs, Deploy Destinations on the Edit menu, Preview Output in Browser, job build options, project-as-Stationery, `-q`, `--dryrun`, reliable `Last Run Result`) is 2026.1. The trial projects are already rebased to 2026.1 (`this repo:` recent commits), so the guide should assume 2026.1 and avoid documenting older behavior.
7. **First-launch experience.** The Express trial project "opens automatically on first launch" of Express (`this repo: latest/online-trial-guides/express-trial/express-trial-guide.md`). Nothing equivalent is documented for the AutoMap Administrator (no seeded trial job). Whether the trial installer should pre-drop a job folder into `Documents\WebWorks ePublisher AutoMap\Jobs` is an open design decision — the drop-in discovery behavior makes it technically trivial.
8. **Staging-folder discoverability.** Stationery-based jobs put output in `Documents\WebWorks ePublisher AutoMap\Staging\<JobName>\Output\<Target>\`, which the docs themselves flag as a common "where's my output?" trap (`skill: references/job-file-guide.md`, "Can't Find Build Output"). A trial guide should either use a Folder destination from the start or call the staging path out explicitly.

---

## Follow-up findings (2026-08-21, targeted verification pass)

A second pass against `trunk` source, installer scripts, and the installed 2026.1 product resolved several gaps above.

### Gap 2 CLOSED — trial output is NOT watermarked

No shipped format transform calls `wwadapter:TemporaryLicense`. Case-insensitive search across all of `trunk` finds the identifier only in engine code and generated docs (`trunk: dev/source/windows/dotnet/WebWorks/Publish/Core/Engine/Extension/Adapter.cs:102`, whose XML-doc comment is itself the source of the "Evaluation Version" example in `trunk: docs/reference/xslt-extensions/adapter.md`); zero `.xsl`/`.xslt` hits. Only 8 format `.xsl` files use the `wwadapter:` prefix at all, and the complete set of called functions is PDF/TOC/image plumbing (`trunk: files/webworks/Formats/Shared/pdf/generate.xsl` and friends). All 19 shipped `.wez` format packages were unzipped and scanned (0 hits), and the installed `C:\Program Files\WebWorks\ePublisher\2026.1\Formats` tree (336 `.xsl`) has no match. The extension also gates on the *source-tool adapter* (Word/FrameMaker) license (`trunk: .../Common/ToolAdapter/IToolAdapter.cs:125`), not the ePublisher evaluation contract. No `Evaluation`/`watermark`/`Trial` strings exist in the format tree.

### Gap 7 informed — how trial materials are seeded, and where they live for end users

Two-stage mechanism, verified in source and on disk:

1. **Installer** drops `.wez` archives into `C:\Program Files\WebWorks\ePublisher\<major>.<minor>\ePublisher {Express|Designer}\Evaluation\` (`trunk: products/Express/ExpressInstaller/NSIS Installer/Include/install_files.nsh:388-390`; Designer counterpart at `products/ePublisher/.../install_files.nsh:391-394`).
2. **First app launch** extracts them into `MyDocuments` — once, gated on `DefaultDirectoriesCreated` (`trunk: dev/source/windows/dotnet/WebWorks/Publish/Redstone/RedstoneApplication.cs:396-480`; Designer: `.../Publisher/PublisherProApplication.cs:475-571`). Express then auto-opens the trial `.wrp` and launches the online trial guide URL when the recent-project list is empty (`trunk: .../Redstone/CommandLineHandler.cs:247-284`; Designer: `.../Publisher/Program.cs:203-234`).

End-user paths a trial guide can rely on:

| Item | Trial user's machine |
|---|---|
| Express trial project | `Documents\ePublisher Express Projects\ePublisher Express Trial Project\ePublisher Express Trial Project.wrp` |
| Express trial Stationery | `Documents\ePublisher Stationery\ePublisher Express Trial Stationery\` |
| Designer trial project | `Documents\ePublisher Designer Projects\ePublisher Designer Trial\` |

Caveats: the folder names are **localized** (`Projets ePublisher Express` on fr UI, etc. — `trunk: .../Redstone/Resources/SpecialStrings.resx:120` and siblings), and `Documents` may be OneDrive-redirected. A **Reset Evaluation Materials** button in Application Preferences re-runs the extraction, deleting and replacing the trial folders (`trunk: .../Redstone/UserInterface/Dialogs/ApplicationPrefDialog.cs:749-758`) — useful as a trial-guide recovery tip, but a warning to users who edited the trial project.

### AutoMap ships as its OWN installer

AutoMap is not a component of the Express or Designer installers: it has a dedicated NSIS project (`trunk: products/AutoMap/AutoMapInstaller/NSIS Installer/automap_installer_x64.nsi`) built as a separate step (`trunk: builds/cmd/build_x64.bat:129-144`), and "automap" does not appear in the Express/Designer installer file lists. An AutoMap trial guide therefore needs an explicit "download and install AutoMap" prerequisite (Express first — install-order note in `epublisher-docs: planning-and-installing.md`).

### Still open

Gap 1 (does the self-serve evaluation Contract ID license the AutoMap component?) is a licensing/CRM question and remains unresolved by both repos. *(Resolved 2026-08-21 by product owner: Contract IDs are configurable per component; evaluation contracts can include AutoMap.)*

---

## Second verification pass (2026-08-21): standalone install, seeding gap, composition mechanics

Prompted by the decision to reposition AutoMap as the primary no-design evaluation path (replacing Express in the funnel).

### AutoMap 2026.1 is fully standalone — no Express required (HIGH confidence)

The legacy "install Express first" claim is mechanically false in 2026.1 and the docs have already been corrected (`epublisher-docs: legacy/welcome-to-epublisher/planning-and-installing.md:289,310` — "independent components: you can install any combination... in any order"; correction commits `cf71142`, `4aa9ad9`). The AutoMap installer checks only .NET 4.7.2/Java/Ghostscript (`trunk: products/common/windows/NSIS Installer/install.nsh:17-81`) and ships the entire publishing engine itself: `WebWorks.Publish.Core.dll`, `Transformer.exe`, all 15 shared Formats including Reverb 2.0, all adapters, and third-party engine deps (`trunk: products/AutoMap/AutoMapInstaller/NSIS Installer/Include/install_files.nsh`, `install_files_formats_shared.nsh`). The runtime resolves engine paths relative to the shared version root (`..\Formats` etc. in `WebWorks.Automap.exe.config`), never through Express. **A trial user who installs only AutoMap gets a fully working system — GUI and CLI.** One constraint: version parity if other components are also installed.

### No evaluation seeding or trial-URL exists in AutoMap today (HIGH confidence)

Confirmed four ways (source grep, installer manifest, installed filesystem, entry-point read). The dev work to add it has an exact three-part template in Express:

1. **Installer**: an `Evaluation` entry in the AutoMap installer's `paths.json` carrying `.wez` archives (Express model: `trunk: products/Express/ExpressInstaller/NSIS Installer/Include/paths.json:143-145`).
2. **First-launch extraction**: `AutomapApplication.OnInitializePreferences` (`trunk: dev/source/windows/dotnet/WebWorks/Automap/Core/AutomapApplication.cs:463-474`) is currently a stub that already flips the one-shot `DefaultDirectoriesCreated` guard; Express's seeding logic to mirror is `RedstoneApplication.cs:396-480`, and the shared `ExtractEvaluationWEZ` helper (`Publish/Core/PublisherApplication.cs:402`) is already reachable from AutoMap.
3. **Trial-URL auto-open + Help-menu item**: Express model at `Redstone/CommandLineHandler.cs:247-284` (opens `http://static.webworks.com/docs/epublisher/<ver>/express/trial/`) and `RedstoneApplication.cs:293-299`. AutoMap's Help menu currently links only marketing/support pages (`Automap/AutomapUI/UI/JobsForm.cs:2045-2055`).

### Composition jobs: minimum viable local setup (HIGH confidence; one MEDIUM item)

From `trunk: docs/guides/federated-parcel-composition.md`, `epublisher-docs: legacy/epublisher-interface/automating-projects.md` §"Creating a Composition Job", and `skill: references/composition-jobs.md` (+ working fixtures in the skill's tests).

- A `.wacj` *references* existing `.waj` jobs (`.sln`/`.csproj` analogy); members carry a **role**: exactly one **Shell** (chrome; deploys `--deployscope=shell`; normally a zero-document build via Reverb 2.0's `generate-empty-project`), **Parcel** (content; `--deployscope=groups`), or **Infer**.
- **Derivative vs federated is the pivotal switch.** With `build="true"` (the Administrator's default when adding members — note the grammar default is the opposite), the composition builds each member itself and **forwards `--target`, `--destination`, and `--deployscope` derived from the role, overriding the member's own settings**. This makes a trial composition self-contained: seeded jobs can remain ordinary, individually-runnable publication jobs, and the composition handles scoping/destination itself. With `build="false"`, members must have been built and deployed beforehand on their own cadence.
- **Fully local is the documented acceptance path**: shell job + parcel job(s) + one `.wacj` with an **inline Folder destination** (`Action="file"`, no credentials, no machine seeding). Requirements: Reverb 2.0 only; all members same output format; exactly one compose-capable target resolvable per member.
- The composed result is one merged Reverb site: spliced combined TOC in the shell's `index.html`, regenerated aggregate `url_maps.xml`/`sitemap.xml`, bumped cache key. Merge Settings: Automatic (discovery — new parcels appear with no `.wacj` edit), Custom (declared placements), or hybrid (`discover="true"`).
- **Gotchas that shape a trial guide**: reference parcels by group NAME, never GroupID (GIDs regenerate); never point an Everything-scope job at the shared mirror (scoped Clean wipes it); validation runs before any member build (fast failure); the Administrator does not preserve XML comments in job files; composition logs relay member `[WARN]`/`[ERROR]` lines that the closing tally does not count; `--dryrun` against a Folder destination skips the compose entirely.
- ~~**MEDIUM-confidence open item:** whether a *composed* site renders correctly over `file://`~~ *Resolved 2026-08-22 by product owner: `file://` works for composed sites.*

### Product-owner facts (2026-08-23)

- The **AI Assistant** target setting can be enabled in output, but a live chat response requires a WebWorks Platform login (free to try) *and* hosting the output on an Internet domain. Unhosted output still shows the AI Assistant UI — chat requests return an expected error. Look-and-feel is evaluable locally; the full experience is not.
- The second evaluation Stationery is a variant of Quantum Sync Stationery differing in **chrome only** (shell look and feel); it ships in the AutoMap evaluation payload, not the Designer installer. Authoring constraint from the re-skin mechanics below: keep style mappings identical between the two Stationeries so the visual delta is honest chrome/theme change.

### Re-skin mechanics (2026-08-22 pass, for the second-Stationery demo)

- **A job's origin is editable after creation** (HIGH confidence). The Edit Job window reuses the wizard's Job Info page with a live, un-gated origin field (`trunk: dev/source/windows/dotnet/WebWorks/Automap/AutomapUI/UI/JobEditorForm.cs:57`, `.../Wizard/Panel/JobInfoWizardPage.cs:70-91`; docs: `epublisher-docs: legacy/epublisher-interface/automating-projects.md:455` "You can change the selection"). A stationery-based job can be repointed Stationery A → B freely; what cannot change is the job's *kind* (stationery-staged vs build-in-place, recorded as `useAsStationery` at creation). Hand-editing `<Project path>` in a `.waj` is supported. Hard error (with guidance) if the new Stationery lacks a target the job declares.
- **A full re-skin of a composed site requires ALL members to rebuild against the new Stationery** (HIGH on mechanism). Styling is split: root `css/` (SCSS skin/theme) is shell-owned and styles every page site-wide, but each parcel's deployed slice carries its own style-mapping CSS (`<GroupDir>/.../css/<Doc>.css`) and its spliced TOC fragment from its own build (`trunk: docs/guides/federated-parcel-composition.md:170-177,543-547`; `trunk: files/webworks/Formats/WebWorks Reverb 2.0/Transforms/files.xsl:430`, `Pages/Page.asp:35-41`). A shell-only rebuild is a *partial* re-skin that can look complete for pure SCSS-variable changes but leaves parcel content on the old design.
- **No design-mismatch detection exists.** Compose only cross-checks format name/version; the parcel descriptor records no Stationery identity, so a design-mixed site publishes silently (`.../Transforms/descriptor.xsl:294-303`; `automating-projects.md:666-679`). A re-skin walkthrough must therefore teach "repoint every member, then re-run the composition" — cheap in the trial's derivative composition, which rebuilds all members in one run anyway. Cache note for S3: root `css/` serves at `max-age=300`, so re-skins propagate within ~5 minutes there (irrelevant for local Folder mirrors). Related product-owner note: S3 deployment is more valuable than the original "mention but don't demo" framing suggested — Reverb leverages caching, so production updates require correct S3 configuration, which the 2026.1 Deploy Destination features fully enable. Not locally demonstrable, but it earns real weight in evaluation-depth content.
