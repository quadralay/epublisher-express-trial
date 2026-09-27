---
title: "feat: AutoMap Trial trunk handoff spec (installer payload, evaluation workspace, trial guide link)"
type: feat
status: draft
date: 2026-09-23
origin: `docs/research/automap-trial-features.md`
---

# AutoMap Trial trunk handoff spec

## Overview

### Goal

Implement the product-side work that makes the AutoMap evaluation self-contained: package one Evaluation archive in the AutoMap installer, seed it into one shared machine-wide workspace during interactive registration, link to the versioned trial guide from the installer Finish page, add a required reset action, and add a Getting Started topic to online AutoMap help. This is a trunk implementation handoff; no product source is changed by this document.

This revision is dated 2026-09-27 and records the maintainer-approved workspace-only design. The decision record is `docs/adr/0006-evaluation-workspace-in-public-documents.md`.

### Design history

The 2026-09-23 revision specified first-launch extraction (superseded by ADR-0005); the 2026-09-26 revision specified install-time seeding with a choice of default-root or workspace modes; the 2026-09-27 revision (this one) moved to workspace-only under Public Documents per ADR-0006, after AutoMap Workspaces landed as SVN r36120.

### Template and design

Express seeds in its application constructor, which runs before its `--register` branch (`Redstone/Program.cs:58`; branch at :143-162). The Express installer runs `--register` during installation, so its materials in practice land during installation for the installing account. AutoMap mirrors that install-time timing in its own explicit `--register` branch, rather than a shared constructor also used by CLI and scheduled-task launches. Those non-installer runs therefore never seed.

See `docs/research/automap-trial-features.md`, "Gap 7 informed" and "No evaluation seeding or trial-URL exists in AutoMap today". The primary evaluation path and product independence are recorded in `docs/adr/0001-automap-primary-evaluation-path.md`. The on-disk contract is `docs/agents/extraction-layout.md`; seeded job behavior and rehearsal evidence are in `docs/agents/seeded-jobs.md`. Destination rewriting follows `docs/adr/0004-seeded-job-folder-destinations.md` and `scripts/stage_seeded_jobs.py`.

### What already exists (verified against trunk)

| Capability | Existing source or state | Handoff consequence |
|---|---|---|
| AutoMap Help archive | Express template `paths.json` 142-144; AutoMap Help key x64 `paths.json` 149-151, x86 `paths_x86.json` 125-127 | Add Evaluation entries alongside Help. |
| Installer file list | `install_files.nsh` 393-394 (generated) | Edit `paths.json` and regenerate; do not hand-edit generated output. |
| Registration step | `products/AutoMap/Installer_Helper/Installer_Helper/Installer_Helper.cs:194-210` runs Administrator exe with `--register`, appending `--silent` for silent installs and `--update` for repairs/updates; invoked from `products/common/windows/NSIS Installer/install.nsh:112`; installer declares RequestExecutionLevel admin (`resources.nsh:124`) | Seed only in the interactive registration branch; workspace content is shared. |
| `--register` branch | `Automap/AutomapUI/AutomapUI.cs:151-171` constructs `AutomapApplication.Instance`, calls OnRegistration, shows LicensingInfoForm unless `--silent`, and returns without disposing the app | Place extraction after OnRegistration and before the licensing form. |
| Evaluation extraction helper | `Publish/Core/PublisherApplication.cs:391-425` | Wrap the `protected` `ExtractEvaluationWEZ` in one public `AutomapApplication` method shared by `--register` and Reset; verify sentinels because it reports no result. |
| Finish page | `products/common/windows/NSIS Installer/resources.nsh:150-166` uses `MUI_FINISHPAGE_RUN` for Launch and `MUI_FINISHPAGE_SHOWREADME` for the readme; strings are LangStrings in i18n/{english,french,german,japanese}.nlf, e.g. `english.nlf`:40-41 | Add an AutoMap-only Finish-page link in the free link slot. |
| Job deletion | Administrator Delete command with confirmation prompt, `Automap/AutomapUI/UI/JobsForm.cs:1973`, DeleteSelectedJobs at 1454 | Reset restores the three seeded folders after a user deletes one. |
| Preferences Miscellaneous group | `Automap/AutomapUI/UI/PrefEditorPanel.resx:292` | Place required Reset Evaluation Materials here. |
| Scheduled tasks | `Automap/Core/TaskSchedulerManager.cs`: task action embeds quoted absolute job path (258-263); mismatching argument disowns task (188-197); UpdateTask rewrites only a missing exe path, never job argument (417-430) | Keep seeded job paths stable. |
| Workspaces | Trac #2919, committed as SVN r36120: named switchable jobs/staging roots with a machine-wide registry and active workspace | Seed into one registered workspace shared by all users. |

All trunk references below use paths relative to trunk's dev\source\windows\dotnet\WebWorks\ unless a path starts with products/ or another stated root. Line numbers are current verified anchors, not a claim that adjacent generated files should be edited by hand.

## Installer Evaluation payload

### Archive contract

Create a single plain ZIP-format .wez archive named `Exp_AutoMap.wez`, using 7-Zip `-tzip -mx=9`, from the CONTENTS of `latest/local-trial-projects/WebWorks ePublisher AutoMap/`. Do not add a wrapping directory. Root entries are `Evaluation/` and `Jobs/`. Add the packaging command to `/package-trials`; destination is `SVN_LOCAL_PATH/products/AutoMap/Evaluation/Exp_AutoMap.wez`, beside a `README.md`, matching `products/Express/Evaluation/`.

The archive contains 1,083 files and 21,379,809 uncompressed bytes. The prebuilt path manifest is [`docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec-manifest.txt`](2026-09-23-feat-automap-trial-trunk-handoff-spec-manifest.txt); it lists every archive member relative to the mirror root. Do not create the archive from git ls-files or another tracked-file-only list.

| Archive subtree | Files | Contents |
|---|---:|---|
| `Evaluation/Quantum Sync Stationery/` | 535 | Stationery package, including generated snapshots and baseline. |
| `Evaluation/Quantum Sync Midnight Stationery/` | 535 | Variant package, including generated snapshots and baseline. |
| `Evaluation/Quantum Sync Source Docs/` | 10 | Book, Release Notes, topics, and architecture image. |
| `Jobs/` | 3 | One .waj per seeded job. |
| Total | 1,083 | 21,379,809 bytes uncompressed. |

The 521 files under each `Formats/WebWorks Reverb 2.0.base/` and `Formats/PDF - XSL-FO.base/` tree are verbatim copies of shipped format packages; preserve them in the ZIP but do not enumerate them here. Each Stationery's other 14 files are:

- Quantum Sync `Stationery.wxsp` or Quantum Sync Midnight `Stationery.wxsp` and the matching .manifest.
- `Files/favicon.png`, `Files/footer-logo.png`, `Files/footer-logo.svg`, `Files/og.png`, `Files/pdf-cover.png`, and `Files/toolbar-logo.svg`.
- `Settings/PDF/schema.json`, `Settings/PDF/settings.json`, `Settings/Web Help/schema.json`, and `Settings/Web Help/settings.json`.
- `Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss` and `custom.scss`.

The source docs' 10 named files are `quantum-sync.md`, `release-notes.md`, `images/quantum-sync-architecture.svg`, and `topics/features.md`, `topics/getting-started.md`, `topics/glossary.md`, `topics/overview.md`, `topics/settings.md`, `topics/sync-modes.md`, and `topics/troubleshooting.md`. The jobs are `Quantum Sync Help/Quantum Sync Help.waj`, `Quantum Sync Release Notes/Quantum Sync Release Notes.waj`, and `Quantum Sync Site Shell/Quantum Sync Site Shell.waj`.

### Packaging source and generated content

Build the archive from the packaging machine's complete WORKING TREE, not git alone. Git tracks only 20 of the 1,083 files: three .waj files, two .wxsp files, ten source-doc files, and five variant chrome sources (three Files assets and two Sass partials). The other 1,063 files are regenerated: Quantum Sync Stationery by Save as Stationery from the Designer Trial project (`docs/agents/release-migration.md`); Quantum Sync Midnight Stationery by `scripts/sync_variant_stationery.py` (ADR-0003).

Before packaging, run `python scripts/sync_variant_stationery.py --check` from repo root and require exit code 0. This is a read-only drift check. The ignored Files/, Formats/, Settings/, and .manifest content must still be present when 7-Zip runs. The Express Trial Stationery package uses the same arrangement; its Files/, Formats/, Settings/, and .manifest are gitignored too (.gitignore lines 9-12; line 8 is the Express project's manifest).

The archive and `README.md` now exist in the trunk working copy at `C:\Repo\ePublisher_debug\trunk\products\AutoMap\Evaluation\Exp_AutoMap.wez` (6,448,174 bytes, about 6.4 MB compressed); 7z l reports 1083 files and 246 folders, matching the manifest count. Archive and `README.md` are unversioned in that SVN working copy (svn status shows a question mark for each), awaiting maintainer svn add and commit.

### Installer wiring

Add an `"ePublisher AutoMap\\Evaluation"` entry to both AutoMap installer manifests, shaped like neighboring Help mapping and pointing its src at the working-tree .wez archive:

- `products/AutoMap/AutoMapInstaller/NSIS Installer/Include/paths.json` (x64), next to Help key at lines 149-151.
- `products/AutoMap/AutoMapInstaller/NSIS Installer/Include/paths_x86.json`, next to Help key at lines 125-127.

Express template entry is at Express `paths.json` 142-144 (research note's "143-145" drifted by one); copy its shape next to AutoMap Help. `collector.py` regenerates `install_files.nsh` and `uninstall_files.nsh` from these JSON files. Do not hand-edit generated .nsh output. AutoMap `install_files.nsh` lines 393-394 show today's Help SetOutPath/File pair as the output sanity-check anchor.

No `App.config` change is needed. `EvaluationFolder` falls back to executable directory plus `Evaluation`. Installed archive path is `C:\Program Files\WebWorks\ePublisher\2026.1\ePublisher AutoMap\Evaluation\Exp_AutoMap.wez`.

## Evaluation workspace

### Definition and registration

Define `<ws>` as Environment.SpecialFolder.CommonDocuments plus "WebWorks ePublisher AutoMap\Quantum Sync Trial"; on a default Windows install this resolves to `C:\Users\Public\Documents\WebWorks ePublisher AutoMap\Quantum Sync Trial`. There is one `<ws>` per machine, shared by every user.

Register it as an AutoMap workspace: Name "Quantum Sync Trial", `JobsDirectory` `<ws>\Jobs`, `StagingDirectory` `<ws>\Staging`. The model is `Automap/Core/AutomapWorkspace.cs:28-165` (Name, `JobsDirectory`, `StagingDirectory`). There is no workspace manifest file (`automap-workspace.xml`); seeded jobs keep their inline Folder destinations exactly as before.

### Why shared

The workspace registry `Workspaces.prefs` (`Automap/Core/AutomapWorkspaceRegistry.cs:37`, 51-59) and active-workspace selection (`AutomapUIPrefs`.`ActiveWorkspace`, key `ActiveWorkspace` in `AdminUI.prefs`, `Automap/AutomapUI/AutomapUIPrefs.cs:153-163`) both live in %ProgramData%\WebWorks\ePublisher AutoMap\2026.1\ and are machine-wide, because AutoMap constructs its preferences with base(true) (`Automap/Core/AutomapApplication.cs:275-276`; `Publish/Core/PublisherPrefences.cs:613-630`). A per-user Documents folder would put one user's profile path into every user's workspace list, and two per-user copies of a seeded job would fight over one machine-wide scheduled task name "waj `<job name>`" (`Automap/Core/TaskSchedulerManager.cs:25`, 156-159).

A shared folder matches the registry's scope: one job path per seeded job, one task per seeded job, and any user can run it. Public Documents is not redirected to OneDrive, so the placeholder problem that drove the create-only-when-absent rule does not arise here.

### Access control

Default Public Documents grants inheritable Modify to INTERACTIVE, SERVICE and BATCH (checked with icacls on a developer machine), so files the elevated installer extracts stay writable for interactive users and scheduled tasks. %ProgramData%\WebWorks grants BUILTIN\Users full control inheritably (`Publish/Core/PublisherPrefences.cs:803-853`), so any user's Reset can update `Workspaces.prefs`. The acceptance test must confirm these permissions on a clean machine.

### Path length, upgrades, and title bar

The deepest payload file is 126 characters relative to the archive root; under the default `<ws>` it is 199 characters, inside MAX_PATH.

`Workspaces.prefs` is carried forward to the next version's preferences folder (`Publish/Core/PublisherPrefences.cs:709`), copied only when the target is missing.

With a named workspace registered, the Administrator shows "Quantum Sync Trial - `<product>`" when it is active (`Automap/AutomapUI/UI/JobsForm.cs:262-273`). The workspace name is data, not a resource, so it is the same string in every UI language.

### Staging selection

The CLI picks a job's staging folder by matching the job path against registered workspaces (`Automap/Core/AutomapCLI.cs:744-820`, AutomapWorkspaceRegistry.FindForJobFile at :196-220), so seeded jobs, their scheduled tasks, and the guide's own composition all stage under `<ws>\Staging`.

### Localized names

| Segment | Varies? |
|---|---|
| `<Public Documents>` display name | Localized, but resolved with CommonDocuments rather than by display name. |
| WebWorks ePublisher AutoMap | No; fixed literal in every UI language. |
| Quantum Sync Trial | No; fixed literal in every UI language. |
| `Jobs`, `Staging`, `Output`, `Evaluation` | No; fixed literals in every UI language. |
| Every name below those folders | No; fixed literal in every UI language. |

### Workspace layout, folders, and relative paths

This tree reproduces `docs/agents/extraction-layout.md`, "The layout on a trial user's machine". `<ws>` is the shared Public Documents evaluation workspace.

```
<ws>\                                           evaluation workspace
+-- Jobs\                                           seeded jobs land here
|   +-- Quantum Sync Help\Quantum Sync Help.waj
|   +-- Quantum Sync Release Notes\Quantum Sync Release Notes.waj
|   +-- Quantum Sync Site Shell\Quantum Sync Site Shell.waj
+-- Staging\                                        this workspace's staging folder
+-- Output\                                         seeded jobs and in-guide composition deploy here (Output\<job name>\, created by first run)
+-- Evaluation\                                     AutoMap evaluation materials
    +-- Quantum Sync Stationery\
    |   +-- Quantum Sync Stationery.wxsp
    |   +-- Quantum Sync Stationery.manifest
    |   +-- Files\
    |   +-- Formats\
    |   +-- Settings\
    +-- Quantum Sync Midnight Stationery\           variant Stationery (chrome-only re-skin)
    |   +-- Quantum Sync Midnight Stationery.wxsp
    |   +-- Quantum Sync Midnight Stationery.manifest
    |   +-- Files\
    |   +-- Formats\
    |   +-- Settings\
    +-- Quantum Sync Source Docs\
        +-- quantum-sync.md                           Quantum Sync book (includes topics/*.md)
        +-- topics\
        +-- images\
        +-- release-notes.md                          Release Notes document
```

Folder contract: job identity is folder name = .waj name = `<Job name>`. The Administrator loads every job folder under Jobs when it starts and when `JobManager` sets the jobs folder (`JobsForm.cs:129`, 2065-2069), so no import is needed. There is no file-system watcher: a job folder added while the Administrator runs appears only after a reload. `Output\<name>` is created by first run. Seeded jobs' Folder destinations deploy there; Staging remains the active workspace's staging folder.

Relative-path rule: AutoMap resolves `<Project path>` and every `<Document path>` from the directory containing the .waj. Exactly two `..\` segments from `Jobs\<name>\<name>.waj` reach `<ws>`. Keep project and document paths relative, with backslashes, starting `..\..\Evaluation\`; never reference Express/Designer folders or climb above `<ws>`. Examples: `..\..\Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp`, `..\..\Evaluation\Quantum Sync Midnight Stationery\Quantum Sync Midnight Stationery.wxsp`, `..\..\Evaluation\Quantum Sync Source Docs\quantum-sync.md`, and the corresponding `release-notes.md` path.

### Job destination rewrite

Repo .waj files carry a Folder destination Configuration Value of `..\..\Output\<name>`. After extraction, rewrite only each relative Folder destination value to an absolute `<ws>\Output\<name>`. `Publish/Core/Deployment/FolderDeployTarget.cs:75` uses that value verbatim. The scheduler's working directory is System32, so leaving it relative is not reliable (ADR-0004; `docs/agents/seeded-jobs.md`, "Destination strategy").

Use `scripts/stage_seeded_jobs.py` as reference: identify inline `DeploySetting` elements with Action="file", rewrite relative Configuration Value paths against the destination job directory, preserve absolute values, and leave XML Project and Document paths relative. Scheduled tasks stay valid because job and Evaluation paths do not change.

`scripts/rehearse_seeded_jobs.ps1` rehearses this layout and rewrite; `docs/agents/seeded-jobs.md`, "Rehearsal results", records the passing run. The rehearsal supports the archive contract but does not replace Windows installer checks.

## Install-time seeding

### Where it runs

Run seeding in the `--register` branch of `Automap/AutomapUI/AutomapUI.cs` (151-171), right after OnRegistration(...) and before the licensing form, only when `--silent` is absent. Do not place it in `AutomapApplication.OnInitializePreferences` (463-474), which also runs for CLI and scheduled-task initialization, or at Administrator startup.

The installer requests admin, so seeding runs under the elevated installing account. The installer calls RequireNoRunningEPublisherProducts before installing (products/common/windows/NSIS `Installer/install.nsh:54`, 131, 203, 264), so no Administrator is running to overwrite the registry from its cached copy.

Silent installs skip seeding; this is a deliberate break from Express. The narrower alternative, if ever wanted, is to skip only as SYSTEM. `DefaultDirectoriesCreated` is not usable for seeding gating: `--register` only marks its preference dirty and returns without disposing or flushing the app.

### Extraction and sentinels

The public `AutomapApplication` wrapper calls `protected` `ExtractEvaluationWEZ` on `PublisherApplication` (`Publish/Core/PublisherApplication.cs:391-425`), modeled on Designer's `Publish/Publisher/PublisherProApplication.cs:475-587` ResetEvaluationMaterials. It extracts `Exp_AutoMap.wez` into `<ws>` itself so Evaluation and Jobs are siblings. The helper creates the destination only when absent, then extracts; its catch around lines 420-424 is empty. Never overwrite an existing workspace during installation. After extraction, verify all sentinels: the three seeded .waj files and `Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp`. Stop if any sentinel is missing.

The job Folder destination rewrite follows `scripts/stage_seeded_jobs.py`. Rewrite only relative Action="file" Configuration Value destinations to absolute `<ws>\Output\<name>`; preserve absolute values and leave Project and Document paths relative. `Publish/Core/Deployment/FolderDeployTarget.cs:75` uses the Folder value verbatim. The scheduler's working directory is System32, so relative Folder destinations are not reliable (ADR-0004). `scripts/rehearse_seeded_jobs.ps1` rehearses the layout and rewrite.

### Steps

1. If `<ws>` already exists, skip steps 2 and 3 and never overwrite anything in it. Steps 4 and 5 still run, so a workspace folder whose registry entry was lost is registered again.
2. Extract `Exp_AutoMap.wez` into `<ws>` through the public `AutomapApplication` method; verify the sentinels; stop if any sentinel is missing.
3. Absolutize the three seeded .waj Folder destinations to `<ws>\Output\<name>` (the rewrite rule itself is unchanged from this spec's Job destination rewrite).
4. Register or update the "Quantum Sync Trial" entry through AutomapAdmin.AutomapUIWorkspaces (`Automap/AutomapUI/AutomapUIWorkspaces.cs`); this is callable from `--register` because it needs only the `AutomapPreferences` service, registered in the `AutomapApplication` constructor at `AutomapApplication.cs`:278-281. Call `Validate`(ws, originalName) (:251-292) with originalName = "Quantum Sync Trial" when an entry with that name already exists, and null when adding a new entry; `Validate` otherwise rejects the entry's own name (:275) and its own jobs folder (:280). If validation fails (for example, a customer workspace already uses that folder), stop without storing anything. Then call `Store`(originalName, ws) (:169-212), which saves `Workspaces.prefs` immediately but does not itself validate or create folders.
5. Activate the workspace only on a fresh machine: no named workspace other than Quantum Sync Trial is registered AND Default's Jobs folder holds no jobs. Count both job subfolders and loose .waj/.wacj files at the Jobs root, because `JobManager.LoadAllJobs` loads both (`Automap/Core/JobManager.cs:296-304`). Default's Jobs folder is `AutomapUIWorkspaces.Default.JobsDirectory` (:75-83); when unset it resolves to the elevated installing account's Documents folder, which is acceptable for this gate only. `Activate` (:155-161) sets `ActiveWorkspace` and flushes `AdminUI.prefs`; activation is machine-wide. On an upgrade, or a machine with existing jobs, the trial workspace is registered but NOT activated, so an existing customer's Administrator keeps its current view; the user picks Quantum Sync Trial from the workspace switcher when ready.

Seeding is harmless on upgrades because it lands in its own workspace; activation is what would take over an existing customer's view, hence the split between registering and activating. After uninstall and reinstall, `<ws>` still exists, so nothing is re-extracted; steps 4 and 5 re-register it if its entry was lost with the ProgramData preferences. If `<ws>` was deleted while its entry remains, steps 2 to 4 re-seed it and update the entry.

## Trial guide link and Getting Started topic

Canonical URL: `https://static.webworks.com/docs/epublisher/{VersionDirectoryName}/automap/trial/`; for 2026.1: `https://static.webworks.com/docs/epublisher/2026.1/automap/trial/`. The pattern is also in `docs/agents/extraction-layout.md`, "The trial guide's URL".

In the shared `DEFINE_PAGES` macro (`products/common/windows/NSIS Installer/resources.nsh:127`), which all three product installers invoke, gate the addition with `!if "${productName}" == "${AUTOMAP_STR}"` and add `MUI_FINISHPAGE_LINK` with a new `LangString` such as `open_trial_guide` = "Open the AutoMap Trial Guide", added to all four .nlf files. Set `MUI_FINISHPAGE_LINK_LOCATION` to the versioned URL built from the installer's existing version defines. Both Finish-page checkboxes (Launch and Show Readme) are already used, so the link element is the free slot. Express and Designer Finish pages stay unchanged.

The link appears only on interactive installs (silent installs show no Finish page), at the same time and for the same user as seeding. The browser launches with the installer's elevated token, as does the existing Launch checkbox.

There is no Administrator startup auto-open and no Help-menu item. A startup auto-open needs per-user first-launch state, which ADR-0005 removes. Help > Documentation already opens online AutoMap help (`OnlineDocumentationUri`, `.../automap/help`).

Add a Getting Started topic in the AutoMap help's "Welcome to ePublisher AutoMap" group. This docs-side topic belongs in epublisher-docs, not this repo; it links to the versioned trial guide, states where the installer puts materials, and explains Reset Evaluation Materials. Help ships online independently of the product build; track it here for conceptual coordination, not as Trac #2975 product work.

## Reset Evaluation Materials (required)

Reset Evaluation Materials is REQUIRED, not optional. It serves a second Windows user on a shared machine; a user whose install ran elevated under a different admin account; a user skipped by a silent install; an existing customer who wants the trial activated; anyone who deleted or broke the seeded jobs; and a machine where validation stopped seeding.

Placement is unchanged: Preferences > General > Miscellaneous (`Automap/AutomapUI/UI/PrefEditorPanel.resx:292`); captions adapted from Express ApplicationPrefDialog.*.resx; add new prompt strings in de/fr/ja.

On confirmation, the prompt states that Reset replaces the shared trial materials for every user of this computer. Reset refuses while a seeded job is running: it checks the three seeded names in `JobManager.Manager.Jobs` and tests `JobInfo.Running` (`Automap/Core/JobInfo.cs:292`), which reflects the scheduled task's running state, so another account's scheduled run counts. It deletes only `<ws>\Evaluation` and the three seeded job folders under `<ws>\Jobs`, deleting them directly rather than through `JobManager.DeleteJob`, which also deletes the job's scheduled task (`Automap/Core/JobManager.cs:397-432`, task deletion at :430). It keeps Output, Staging, and every other job in the trial workspace, including jobs a guide reader creates there (Step 2's publishing job and Step 3's Quantum Sync Site composition). It creates `<ws>` if it is missing; extracts, verifies sentinels, and absolutizes destinations; registers or updates the entry as in seeding step 4; Activates it; then reloads the job list explicitly: `JobsForm.EditPrefs` (`Automap/AutomapUI/UI/JobsForm.cs:1593-1599`) calls `ShowJobsFolder(AutomapUIWorkspaces.Active.JobsDirectory)` (:275-293) when the Preferences panel reports a reset, and `JobManager.SetJobDirectory` (`Automap/Core/JobManager.cs:206`) clears and reloads the list even when the folder is unchanged. The Changed handler reloads only when the jobs folder differs (`Automap/AutomapUI/UI/JobsForm.cs:2243-2253`, ShowJobsFolder at :275-293); Reset keeps the same folder, so the handler alone would not fire. Reset never opens a browser. It works for any user under the Public Documents and ProgramData access facts above. Scheduled tasks stay valid because job paths do not change.

### Scheduled tasks

Task names are machine-wide and tasks belong to the account that created them. The guide's Step 4 schedules Quantum Sync Release Notes; another user's Run Now on that job finds a task owned by another account and gets the Schedule dialog and collision warning (v1 Workspaces behavior, `TaskSchedulerManager.cs`:389-414, 446-649). One shared job path per seeded job means the task never points at a different copy.

## Licensing note

Evaluation Contract IDs must include the AutoMap component (application ID 21). AutoMap does not reuse Express .licinfo. The user enters a Contract ID in AutoMap LicensingInfoForm during installer `--register` or through Help > License Keys (`Automap/AutomapUI/AutomapUI.cs:151-171`; `Automap/AutomapUI/UI/JobsForm.cs:2008-2013`).

Seeding, the Finish-page link, and Reset are not license-gated. The evaluation engine limits output to 8 generated documents, applies a Ghostscript-image watermark, and blocks XSL exec. Current seeded jobs are within the generation cap: Quantum Sync Help contains 1 Document element, Quantum Sync Release Notes contains 1, and Quantum Sync Site Shell contains 0 (the intended zero-document shell job).

These engine-level limits refine, rather than reverse, the research note's "Gap 2 CLOSED" conclusion. That finding concerned the absence of a format-level watermark call in shipped transforms. The engine's Ghostscript watermark and generation cap are a separate, narrower mechanism; do not claim that trial output is wholly unconstrained.

## Implementation plan

1. Payload. svn add `products/AutoMap/Evaluation/Exp_AutoMap.wez` and `products/AutoMap/Evaluation/README.md`; add the `"ePublisher AutoMap\\Evaluation"` entry to AutoMap `paths.json` and `paths_x86.json`; let `collector.py` regenerate the .nsh files from those.
2. Core. In `Automap/Core/AutomapApplication.cs`, add a public method that extracts `EvaluationFolder\Exp_AutoMap.wez` into a given workspace folder using the `protected` `ExtractEvaluationWEZ` and returns whether the sentinels exist. Add a small Core helper (for example `Automap/Core/EvaluationMaterials.cs`) that absolutizes relative Action="file" Configuration Values in seeded .waj files, mirroring `scripts/stage_seeded_jobs.py`.
3. Administrator. Add a static orchestrator in Automap/AutomapUI/ (for example `AutomapUIEvaluation.cs`) with SeedAtInstall() and Reset(): it computes `<ws>`, calls the Core pieces, and does register-or-update plus conditional `Activate` through AutomapUIWorkspaces.
4. Registration. In `Automap/AutomapUI/AutomapUI.cs`, the `--register` branch calls SeedAtInstall() after OnRegistration when `--silent` is absent.
5. Preferences. Add a Reset button and handler in `PrefEditorPanel`. The running-job check reads the static `JobManager.Manager` (`Automap/Core/JobManager.cs:170`; `Jobs` at :133) and tests `JobInfo.Running` for the three seeded names. After a reset the panel reports it to `JobsForm.EditPrefs` (`Automap/AutomapUI/UI/JobsForm.cs:1593-1599`), which today discards the dialog result; have it call `ShowJobsFolder(AutomapUIWorkspaces.Active.JobsDirectory)` (:275-293). Add resource strings in AutomapUI strings/ErrorsAndAlert resx files for en, de, fr, ja.
6. Installer Finish page. Add the AutoMap-only `MUI_FINISHPAGE_LINK` in `resources.nsh` and the `LangString` in the four .nlf files.
7. Tests. In the existing `WebWorks.test` project, add tests for destination absolutizing (relative rewritten, absolute kept, Project/Document paths untouched), sentinel verification, the fresh-machine activation rule, and register-or-update with `Validate` originalName. Write the activation rule as a pure function of the named workspaces and Default's Jobs folder path (`AutomapUIWorkspaces.Default.JobsDirectory`, which resolves to `AutomapPreferences.DefaultJobsDirectory`, `Automap/Core/AutomapPreferences.cs:102-108`, when unset), so the test needs no preferences files.
8. Docs and release note. Add the release-note block given below, a glossary entry for the evaluation workspace if the glossary lists product folders, and the AutoMap guides workspace section (external, tracked as Remaining work below, not implemented here).

## Acceptance tests

Run these checks on a clean Windows machine with no WebWorks products installed. Use an evaluation Contract ID that includes AutoMap.

1. Confirm the AutoMap installer installs `Evaluation\Exp_AutoMap.wez` under Program Files.
2. After interactive install, confirm `<ws>` exists under Public Documents with the exact tree below; each absolute Folder destination is under `<ws>\Output\<name>`, while Project and Document paths stay relative.
3. Confirm `Workspaces.prefs` lists Quantum Sync Trial with jobs `<ws>\Jobs` and staging `<ws>\Staging`.
4. On a fresh machine, confirm the first Administrator launch shows title "Quantum Sync Trial - ..." and the three jobs; no browser opens.
5. Confirm the Finish-page link opens the versioned URL; Express and Designer Finish pages are unchanged.
6. Run each seeded job and confirm exit 0, staging under `<ws>\Staging` (the log names the workspace as the staging source), and `<ws>\Output\<name>\index.html`; Explore Output opens it.
7. Sign in as a second, standard (non-admin) Windows user; confirm the same workspace is visible and that user can run a seeded job and Reset (ACL check).
8. Upgrade/install on a machine whose Default Jobs folder holds a job: confirm the workspace is registered but Default stays active.
9. Repair or reinstall with `<ws>` present: edit a .waj first and confirm nothing is overwritten.
10. Silent install: confirm nothing is seeded and no Finish page appears.
11. Confirm CLI and scheduled runs never seed.
12. Reset: confirm the prompt appears; Cancel changes nothing; Confirm restores a deleted seeded job; keeps a user-created job in the workspace; keeps Output and Staging; keeps the existing Release Notes task working; refuses while a seeded job runs; reloads the list without restart; activates the workspace; and opens no browser.
13. Delete `<ws>` then Reset; confirm it recreates the workspace and updates the registry entry.
14. Uninstall removes the Program Files payload and leaves `<ws>` and its registry entry.
15. In de/fr/ja UIs, confirm literal names are unchanged, Reset caption and prompt are translated, and Finish link text is translated.
16. Packaging checks: `sync_variant_stationery.py` --check, `rehearse_seeded_jobs.ps1`, and `stage_seeded_jobs.py` agree with the payload and paths.
17. Confirm the Getting Started topic is live.

## Remaining work

### Product (trunk)

Implement this spec as Trac #2975; commit the staged archive and README; add the release-note entry.

### Docs (epublisher-docs)

Add the Getting Started topic in AutoMap help. The Workspaces article is tracked in quadralay/epublisher-docs#142 and should mention the Quantum Sync Trial workspace.

### Trial guide (this repo, once a build with #2975 exists)

Move the "Where things live" callout and Steps 1-3 paths to `Public Documents\WebWorks ePublisher AutoMap\Quantum Sync Trial`. Step 1 notes the title bar and workspace switcher. Re-capture the Administrator screenshots (title bar shows the workspace) and `automap-new-job.png` for GitHub https://github.com/quadralay/epublisher-express-trial/issues/52 (Trac #2974, r36117 widened the dialog and kept the caption wording, so only the screenshot needs to change). Consider an Explore More line about workspaces.

### Maintainer tooling (this repo)

Update `scripts/rehearse_seeded_jobs.ps1` and the extraction-layout verification recipe to stage under a mock of `<ws>`. Hand-staging now means copying into `<ws>` and registering the workspace in the Administrator.

## Trac ticket #2975

State: filed 2026-09-23; description replaced 2026-09-26 (install-time seeding with a choice between two root modes); the description below (workspace-only, dated 2026-09-27) is meant to replace it again, via a ticket comment citing SVN r36120 and ADR-0006.

Summary: AutoMap - Seed a shared evaluation workspace at install time and link the trial guide from the installer

'''Goal:''' Make the AutoMap trial self-contained: install a shared Quantum Sync Trial workspace under Public Documents, seed it during interactive installation, link to the online trial guide from the Finish page, and provide a reset action.

'''Context:''' AutoMap Workspaces (Trac #2919) landed as SVN r36120. The workspace registry and active workspace are machine-wide, so evaluation materials need one shared job path and staging folder for all users. Evaluation archive Exp_AutoMap.wez contains the Quantum Sync Stationery packages, source docs, and three seeded publishing jobs (1,083 files). It is staged beside README.md in products/AutoMap/Evaluation. The full handoff spec and archive manifest are in docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec.md and docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec-manifest.txt. Decision record: docs/adr/0006-evaluation-workspace-in-public-documents.md. Published trial guide: https://static.webworks.com/docs/epublisher/2026.1/automap/trial/.

'''Acceptance Criteria:'''
 * Installer manifests install Exp_AutoMap.wez beside AutoMap Help; collector.py regenerates file lists and uninstall removes the payload while leaving the shared workspace.
 * Interactive --register extracts to Public Documents\WebWorks ePublisher AutoMap\Quantum Sync Trial only when that folder is absent and never overwrites it, verifies sentinels and rewrites the seeded Folder destinations under its Output folder, then registers or updates the Quantum Sync Trial entry, also when the folder already exists. Project and Document paths remain relative.
 * Seeding activates the workspace only on a fresh machine with no other named workspace and no jobs in Default; upgrades preserve the active view. CLI and scheduled runs never seed.
 * The AutoMap-only Finish-page link opens the versioned trial guide; text is translated in all four installer languages. Express and Designer Finish pages are unchanged.
 * Required Reset prompts, refuses while a seeded job runs, restores only Evaluation and the three seeded job folders, keeps Output, Staging, other jobs and scheduled tasks, registers or updates the workspace, activates it, and reloads the list.
 * Any standard Windows user can access the shared workspace and Reset can update its machine-wide registry entry; confirm ACLs on a clean machine.
 * Each seeded job runs with exit 0 and stages under the workspace; localized UIs keep literal folder names and translate Reset and Finish-link strings.
 * AutoMap help Getting Started topic links to the versioned trial guide and explains workspace location and Reset; uninstall leaves the workspace and registry entry.

'''Technical notes:''' Add a public AutomapApplication method that wraps protected PublisherApplication.ExtractEvaluationWEZ (Publish/Core/PublisherApplication.cs:391-425), verifies sentinels, and a helper that absolutizes only relative Action="file" Folder destinations. Register or update and conditionally activate through AutomapUIWorkspaces; Validate receives the existing name or null for an addition. Reset reloads the job list explicitly because the folder does not change. Workspaces.prefs is machine-wide and carried forward when the next version's target is missing. Full implementation details: docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec.md.

Release note addition, modeled on `products/common/resources/readme.html:804-806`:

{{{
<li id="wwli202975" class="UList_Item" value="1">
  <div class="UList_Paragraph"><a name="p202975">Seeded a shared AutoMap Trial evaluation workspace during installation and added a link to the trial guide on the installer's Finish page (EPUB2975).</a></div>
</li>
}}}
