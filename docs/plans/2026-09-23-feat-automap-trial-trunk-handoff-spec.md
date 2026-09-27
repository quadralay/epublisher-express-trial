---
title: "feat: AutoMap Trial trunk handoff spec (installer payload, install-time seeding, trial guide link)"
type: feat
status: draft
date: 2026-09-23
origin: docs/research/automap-trial-features.md
---

# AutoMap Trial trunk handoff spec

## Overview

### Goal

Implement the product-side work that makes the AutoMap evaluation self-contained: package one Evaluation archive in the AutoMap installer, seed it for the installing user during interactive registration, link to the versioned trial guide from the installer Finish page, add a required reset action, and add a Getting Started topic to online AutoMap help. This is a trunk implementation handoff; no product source is changed by this document.

This revision is dated 2026-09-26 and adopts the maintainer-approved design in docs/adr/0005-install-time-evaluation-seeding.md.

### Superseded design

The 2026-09-23 revision specified extraction on each user's first Administrator launch, a one-shot per-user trial-guide auto-open, and a Help-menu item. ADR-0005 (docs/adr/0005-install-time-evaluation-seeding.md) replaces that design with install-time seeding, an installer Finish-page guide link, and a Getting Started topic in online help.

### Template and design

Express seeds in its application constructor, which runs before its --register branch (Redstone/Program.cs:58; branch at :143-162). The Express installer runs --register during installation, so its materials in practice land during installation for the installing account. AutoMap mirrors that install-time timing in its own explicit --register branch, rather than a shared constructor also used by CLI and scheduled-task launches. Those non-installer runs therefore never seed.

See docs/research/automap-trial-features.md, "Gap 7 informed" and "No evaluation seeding or trial-URL exists in AutoMap today". The primary evaluation path and product independence are recorded in docs/adr/0001-automap-primary-evaluation-path.md. The on-disk contract is docs/agents/extraction-layout.md; seeded job behavior and rehearsal evidence are in docs/agents/seeded-jobs.md. Destination rewriting follows docs/adr/0004-seeded-job-folder-destinations.md and scripts/stage_seeded_jobs.py.

### What already exists (verified against trunk)

| Capability | Existing source or state | Handoff consequence |
|---|---|---|
| AutoMap Help archive | Express template paths.json 142-144; AutoMap Help key x64 paths.json 149-151, x86 paths_x86.json 125-127 | Add Evaluation entries alongside Help. |
| Installer file list | install_files.nsh 393-394 (generated) | Edit paths.json and regenerate; do not hand-edit generated output. |
| Registration step | products/AutoMap/Installer_Helper/Installer_Helper/Installer_Helper.cs:194-210 runs Administrator exe with --register, appending --silent for silent installs and --update for repairs/updates; invoked from products/common/windows/NSIS Installer/install.nsh:112; installer declares RequestExecutionLevel admin (resources.nsh:124) | Seed only in the interactive registration branch; elevated identity determines whose Documents folder is used. |
| --register branch | Automap/AutomapUI/AutomapUI.cs:151-171 constructs AutomapApplication.Instance, calls OnRegistration, shows LicensingInfoForm unless --silent, and returns without disposing the app | Place extraction after OnRegistration and before the licensing form. |
| Evaluation extraction helper | Publish/Core/PublisherApplication.cs:391-425 | Wrap the protected ExtractEvaluationWEZ in one public AutomapApplication method shared by --register and Reset; verify sentinels because it reports no result. |
| Finish page | products/common/windows/NSIS Installer/resources.nsh:150-166 uses MUI_FINISHPAGE_RUN for Launch and MUI_FINISHPAGE_SHOWREADME for the readme; strings are LangStrings in i18n/{english,french,german,japanese}.nlf, e.g. english.nlf:40-41 | Add an AutoMap-only Finish-page link in the free link slot. |
| Job deletion | Administrator Delete command with confirmation prompt, Automap/AutomapUI/UI/JobsForm.cs:1973, DeleteSelectedJobs at 1454 | Reset restores the three seeded folders after a user deletes one. |
| Preferences Miscellaneous group | Automap/AutomapUI/UI/PrefEditorPanel.resx:292 | Place required Reset Evaluation Materials here. |
| Scheduled tasks | Automap/Core/TaskSchedulerManager.cs: task action embeds quoted absolute job path (258-263); mismatching argument disowns task (188-197); UpdateTask rewrites only a missing exe path, never job argument (417-430) | Keep seeded job paths stable; never migrate seeded jobs between roots. |
| Workspaces | Trac #2919, milestone 2026.2, component User Interface: named switchable jobs/staging roots with a per-user registry; existing pair becomes the "Default" workspace, unchanged until a second is added | Use workspace root if the trial-minimal workspace slice ships in the same build. |

All trunk references below use paths relative to `C:\Repo\ePublisher_debug\trunk\dev\source\windows\dotnet\WebWorks\` unless a path starts with products/ or another stated root. Line numbers are current verified anchors, not a claim that adjacent generated files should be edited by hand.

## Installer Evaluation payload

### Archive contract

Create a single plain ZIP-format .wez archive named `Exp_AutoMap.wez`, using 7-Zip `-tzip -mx=9`, from the CONTENTS of `latest/local-trial-projects/WebWorks ePublisher AutoMap/`. Do not add a wrapping directory. Root entries are `Evaluation/` and `Jobs/`. Add the packaging command to `/package-trials`; destination is `SVN_LOCAL_PATH/products/AutoMap/Evaluation/Exp_AutoMap.wez`, beside a README.md, matching `products/Express/Evaluation/`.

The archive contains 1,083 files and 21,379,809 uncompressed bytes. The prebuilt path manifest is [docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec-manifest.txt](2026-09-23-feat-automap-trial-trunk-handoff-spec-manifest.txt); it lists every archive member relative to the mirror root. Do not create the archive from git ls-files or another tracked-file-only list.

| Archive subtree | Files | Contents |
|---|---:|---|
| Evaluation/Quantum Sync Stationery/ | 535 | Stationery package, including generated snapshots and baseline. |
| Evaluation/Quantum Sync Midnight Stationery/ | 535 | Variant package, including generated snapshots and baseline. |
| Evaluation/Quantum Sync Source Docs/ | 10 | Book, Release Notes, topics, and architecture image. |
| Jobs/ | 3 | One .waj per seeded job. |
| Total | 1,083 | 21,379,809 bytes uncompressed. |

The 521 files under each `Formats/WebWorks Reverb 2.0.base/` and `Formats/PDF - XSL-FO.base/` tree are verbatim copies of shipped format packages; preserve them in the ZIP but do not enumerate them here. Each Stationery's other 14 files are:

- `Quantum Sync Stationery.wxsp` or `Quantum Sync Midnight Stationery.wxsp` and the matching `.manifest`.
- `Files/favicon.png`, `Files/footer-logo.png`, `Files/footer-logo.svg`, `Files/og.png`, `Files/pdf-cover.png`, and `Files/toolbar-logo.svg`.
- `Settings/PDF/schema.json`, `Settings/PDF/settings.json`, `Settings/Web Help/schema.json`, and `Settings/Web Help/settings.json`.
- `Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss` and `custom.scss`.

The source docs' 10 named files are `quantum-sync.md`, `release-notes.md`, `images/quantum-sync-architecture.svg`, and `topics/features.md`, `topics/getting-started.md`, `topics/glossary.md`, `topics/overview.md`, `topics/settings.md`, `topics/sync-modes.md`, and `topics/troubleshooting.md`. Jobs are `Quantum Sync Help/Quantum Sync Help.waj`, `Quantum Sync Release Notes/Quantum Sync Release Notes.waj`, and `Quantum Sync Site Shell/Quantum Sync Site Shell.waj`.

### Packaging source and generated content

Build the archive from the packaging machine's complete WORKING TREE, not git alone. Git tracks only 20 of the 1,083 files: three .waj files, two .wxsp files, ten source-doc files, and five variant chrome sources (three Files assets and two Sass partials). The other 1,063 files are regenerated: Quantum Sync Stationery by Save as Stationery from the Designer Trial project (docs/agents/release-migration.md); Quantum Sync Midnight Stationery by `scripts/sync_variant_stationery.py` (ADR-0003).

Before packaging, run `python scripts/sync_variant_stationery.py --check` from repo root and require exit code 0. This is a read-only drift check. The ignored Files/, Formats/, Settings/, and .manifest content must still be present when 7-Zip runs. The Express Trial Stationery package uses the same arrangement; its Files/, Formats/, Settings/, and .manifest are gitignored too (.gitignore lines 9-12; line 8 is the Express project's manifest).

The archive and README.md now exist in the trunk working copy at `C:\Repo\ePublisher_debug\trunk\products\AutoMap\Evaluation\Exp_AutoMap.wez` (6,448,174 bytes, about 6.4 MB compressed); `7z l` reports 1083 files and 246 folders, matching the manifest count. Archive and README.md are unversioned in that SVN working copy (`svn status` shows a question mark for each), awaiting maintainer `svn add` and commit.

### Installer wiring

Add an `"ePublisher AutoMap\\Evaluation"` entry to both AutoMap installer manifests, shaped like neighboring Help mapping and pointing its src at the working-tree .wez archive:

- `products/AutoMap/AutoMapInstaller/NSIS Installer/Include/paths.json` (x64), next to Help key at lines 149-151.
- `products/AutoMap/AutoMapInstaller/NSIS Installer/Include/paths_x86.json`, next to Help key at lines 125-127.

Express template entry is at Express paths.json 142-144 (research note's "143-145" drifted by one); copy its shape next to AutoMap Help. `collector.py` regenerates install_files.nsh and uninstall_files.nsh from these JSON files. Do not hand-edit generated .nsh output. AutoMap `install_files.nsh` lines 393-394 show today's Help SetOutPath/File pair as the output sanity-check anchor.

No App.config change is needed. EvaluationFolder falls back to executable directory plus `Evaluation`. Installed archive path is `C:\Program Files\WebWorks\ePublisher\2026.1\ePublisher AutoMap\Evaluation\Exp_AutoMap.wez`.

## Install-time extraction

### Where it runs

Run extraction in the `--register` branch of `Automap/AutomapUI/AutomapUI.cs` (151-171), right after `OnRegistration(...)` and before the licensing form, only when `--silent` is absent. Do not place it in `AutomapApplication.OnInitializePreferences` (463-474), which also runs for CLI and scheduled-task initialization, or at Administrator startup.

The installer requests admin, so this runs with the elevated token. `Environment.SpecialFolder.Personal` resolves to that account's Documents: the installing user under a UAC consent prompt, or the admin's own Documents when a credentialed admin installs on someone's behalf using over-the-shoulder elevation.

Repairs and updates re-run `--register` with `--update`; existence conditions below make that a no-op in the ordinary case. Silent installs skip seeding; these are typically enterprise/SYSTEM deployments, where materials would land in the system profile. This deliberately diverges from Express, which seeds unconditionally. The narrower alternative gate, if parity is wanted later, is to skip only when `WindowsIdentity.GetCurrent().IsSystem`, not for all silent installs.

### Conditions (existence checks, not the one-shot guard)

An earlier revision claimed the installer's `--register` run flips and persists the `DefaultDirectoriesCreated` guard. That claim is WRONG. The `--register` stub sets the value in memory, but `SetProperty` only marks the store dirty (`Common/Preferences.cs:465-469`); preferences reach disk only through a flush, which happens in `PublisherApplication.Dispose` (`Publish/Core/PublisherApplication.cs:274-312`, Flush at line 297) and when the Administrator's Preferences dialog is confirmed (`Automap/AutomapUI/UI/PrefEditorPanel.cs:609-614`). The `--register` branch does neither: it returns without disposing the app. The guard is first persisted by the first Administrator session or CLI run that disposes the app -- machine-wide, not per-user or per-install. Do not use this guard for seeding gating.

Seed into `<root>` only when ALL of these conditions hold:

(a) `<root>\Evaluation` is absent.

(b) None of the three seeded job folders exist under `<root>\Jobs`.

(c) In default-root mode only, the Jobs folder is absent or holds no job folders (a subfolder containing a .waj or .wacj).

(d) In default-root mode only, no Jobs-folder override is set: `AutomapUIPrefs.JobDir` (`Automap/AutomapUI/AutomapUIPrefs.cs:130`) equals the product default. `JobDir` lives in `AdminUI.prefs`, which is machine-wide (ProgramData, because AutoMap constructs with `base(true)`; `Publish/Core/PublisherPrefences.cs:619-621`), and the Preferences dialog stores it on every OK (`PrefEditorPanel.cs:609`), so a Jobs folder confirmed by one user applies to every user on the machine. It is readable in the `--register` branch because `AutomapApplication.Instance` has already registered `AutomapPreferences` and `AutomapUIPrefs` is in the same assembly. Compare normalized full paths, case-insensitively.

Conditions (c) and (d) protect an existing customer's upgrade from getting trial jobs mixed into a real job list; Express has an analogous carried-forward guard. If any condition fails, do nothing during installation. Reset Evaluation Materials is the later recovery. Never overwrite or delete anything during install.

### Extraction root

`<root>` is one value computed in one place and used by install-time seeding, Reset, and the destination rewrite alike. It has two modes:

- Default-root mode (no Workspaces in the build): `<root>` is `<Documents>\WebWorks ePublisher AutoMap`, whose Jobs and Staging are product defaults (`Automap/Core/AutomapPreferences.cs:93-109`).
- Workspace mode (Trac #2919 ships in the same build): `<root>` is a dedicated trial workspace folder, suggested `<Documents>\WebWorks ePublisher AutoMap\Workspaces\Quantum Sync Trial` (name/location are #2919's call), registered for the installing user as "Quantum Sync Trial" with jobs root `<root>\Jobs`, staging root `<root>\Staging`, and no deploy-settings overlay. Conditions (c)/(d) do not apply because this root is new.

Because the #2919 workspace registry is a per-user preference and `--register` never disposes the app, seeding must explicitly Flush the registry itself rather than rely on Dispose. Layout inside `<root>` is identical in both modes, so payload, seeded jobs' relative paths, and destination rewrite do not change between modes.

### Verify, then rewrite

Seeding and Reset share one public `AutomapApplication` method, modelled on Express's `RedstoneApplication.ResetEvaluationMaterials`, because `ExtractEvaluationWEZ` is `protected` on `PublisherApplication` and `AutomapUI.Main` cannot call it directly. That method calls `ExtractEvaluationWEZ(<archive>, <root>)`, extracting into `<root>` itself (not `<root>\Evaluation`) so `Evaluation\` and `Jobs\` land as siblings. Extracting into `<root>\Evaluation` nests them wrongly and breaks every relative path.

The helper reports nothing. `ExtractEvaluationWEZ` (`Publish/Core/PublisherApplication.cs:391-425`) creates the destination only when absent, then extracts. Do not delete and recreate it: redirected Documents may be in OneDrive, where deletion can leave an empty cloud placeholder. `ZipFile.ExtractToDirectory` throws on any pre-existing file. Its catch near 420-424 is empty ("Silently fail!"); Express also uses bare catches and does not log extraction failures. After extraction, check sentinels: the three seeded .waj files and `Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp`. Only when all exist, run the destination rewrite. If they do not, stop; Reset is the recovery.

### Layout, localized folders, and relative paths

This tree reproduces `docs/agents/extraction-layout.md`, "The layout on a trial user's machine". `<Documents>` is the Windows Personal known folder and may be redirected to OneDrive. Jobs, Staging, Evaluation, Output, and all child names are fixed literals. In default-root mode, `<root>` is `<Documents>\WebWorks ePublisher AutoMap`.

```
<root>\                                           extraction root
+-- Jobs\                                           seeded jobs land here
|   +-- Quantum Sync Help\Quantum Sync Help.waj
|   +-- Quantum Sync Release Notes\Quantum Sync Release Notes.waj
|   +-- Quantum Sync Site Shell\Quantum Sync Site Shell.waj
+-- Staging\                                        default Staging folder (untouched)
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

Folder contract: job identity is folder name = .waj name = `<Job name>`; the Administrator loads every job folder under Jobs when it starts and when the Jobs folder preference changes (`JobManager.SetJobDirectory`, called from `JobsForm.cs:129` and from the `JobsDirectoryChanged` handler at `JobsForm.cs:2065-2069`), so no import is needed. There is no file-system watcher: a job folder added while the Administrator runs appears only after a reload. `Output\<name>` is created by first run. Seeded jobs' Folder destinations deploy there; Staging remains the active workspace's staging folder and is not replaced or moved.

Relative-path rule: AutoMap resolves `<Project path>` and every `<Document path>` from the directory containing the .waj. Exactly two `..\` segments from `Jobs\<name>\<name>.waj` reach `<root>`. Keep project and document paths relative, with backslashes, starting `..\..\Evaluation\`; never reference Express/Designer folders or climb above `<root>`. Examples: `..\..\Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp`, `..\..\Evaluation\Quantum Sync Midnight Stationery\Quantum Sync Midnight Stationery.wxsp`, `..\..\Evaluation\Quantum Sync Source Docs\quantum-sync.md`, and corresponding `release-notes.md` path.

Jobs and Evaluation remain siblings under `<root>`. Extraction targets the selected `<root>` Jobs folder. In default-root mode, a `JobsDirectory` override is outside fresh-install scope; relocating Jobs afterwards breaks seeded jobs' relative paths, as with any relative-path job. A Stationery job stages under `Staging\<name>\Output\<Target>\`; the guide does not send users there.

#### Localized Documents folder names

| Segment | Varies? |
|---|---|
| `<Documents>` known folder | Display name is localized and directory may redirect to OneDrive. Resolve with `Environment.SpecialFolder.Personal`. |
| `WebWorks ePublisher AutoMap`, `Jobs`, `Staging` | No; fixed AutoMap literals in default-root mode. |
| `Evaluation` and every descendant name | No; fixed evaluation-material contract names. |
| Express and Designer folders such as `ePublisher Express Projects` and `ePublisher Stationery` | Yes; those folders are localized and must not be used by AutoMap. |

Seeded jobs are unaffected by UI language because no job path contains a localized segment. Extraction uses the same Personal known-folder lookup and treats names below `<root>` as fixed literals; do not add language-specific folder resources. Guide and screenshot prose should say "your Documents folder", note that Windows may display a localized name or redirect it into OneDrive, and prefer Administrator navigation (job list, job folder, Explore Output) over typed paths.

### Job destination rewrite

Repo .waj files carry a Folder destination Configuration Value of `..\..\Output\<name>`. After extraction, rewrite only each relative Folder destination value to an absolute `<root>\Output\<name>`. `Publish/Core/Deployment/FolderDeployTarget.cs:75` uses that value verbatim. The scheduler's working directory is System32, so leaving it relative is not reliable (ADR-0004; `docs/agents/seeded-jobs.md`, "Destination strategy").

Use `scripts/stage_seeded_jobs.py` as reference: identify inline `DeploySetting` elements with `Action="file"`, rewrite relative Configuration Value paths against the destination job directory, preserve absolute values, and leave XML Project and Document paths relative. Scheduled tasks stay valid because job and Evaluation paths do not change.

`scripts/rehearse_seeded_jobs.ps1` rehearses this layout and rewrite; `docs/agents/seeded-jobs.md`, "Rehearsal results", records the passing run. The rehearsal supports the archive contract but does not replace Windows installer checks.

## Relationship to AutoMap Workspaces (Trac #2919)

Workspaces is the preferred end state: Default stays clean, Reset re-extracts one folder, and removing the trial means removing the workspace.

Ship seeding with a trial-minimal slice of #2919 in the same 2026.1 point build IF ready: workspace registry, switcher, active workspace in the title bar, re-rooting of the jobs list, live-update watcher, staging, composition editor Add-member list, and task-name collision warning. The trial does not need the per-workspace deploy-settings overlay or CLI manifest discovery; seeded jobs carry inline Folder destinations already.

Costs include German/French/Japanese strings, a preferences registry format that 2026.2 inherits, and help and glossary updates. 2026.1 point builds already added AutoMap features; federation and composition jobs need 2026.1.4737+.

If the slice is not ready for the build that ships seeding, ship default-root mode rather than hold up the trial: the published trial guide already assumes seeded jobs exist.

Never migrate seeded jobs between roots. Moving a seeded job orphans any scheduled task a trial user created against it; guide Step 4 schedules "Quantum Sync Release Notes". A later build switching to workspace mode seeds that workspace only for new installs and Reset. Earlier default-root materials stay where they are.

Published guide paths are default-root paths ("Where things live" callout, Steps 1-2). If workspace mode ships, epublisher-express-trial must update the guide callout, add a line saying trial jobs live in the "Quantum Sync Trial" workspace, and replace screenshots whose title bar shows the workspace. This is a follow-up, not implemented here.

## Trial guide link and Getting Started topic

Canonical URL: `https://static.webworks.com/docs/epublisher/{VersionDirectoryName}/automap/trial/`; for 2026.1: `https://static.webworks.com/docs/epublisher/2026.1/automap/trial/`. The pattern is also in `docs/agents/extraction-layout.md`, "The trial guide's URL".

In the shared `DEFINE_PAGES` macro (`products/common/windows/NSIS Installer/resources.nsh:127`), which all three product installers invoke, gate the addition with `!if "${productName}" == "${AUTOMAP_STR}"` and add `MUI_FINISHPAGE_LINK` with a new LangString such as `open_trial_guide = "Open the AutoMap Trial Guide"`, added to all four `.nlf` files. Set `MUI_FINISHPAGE_LINK_LOCATION` to the versioned URL built from the installer's existing version defines. Both Finish-page checkboxes (Launch and Show Readme) are already used, so the link element is the free slot. Express and Designer Finish pages stay unchanged.

The link appears only on interactive installs (silent installs show no Finish page), at the same time and for the same user as seeding. The browser launches with the installer's elevated token, as does the existing Launch checkbox.

There is no Administrator startup auto-open and no Help-menu item. A startup auto-open needs per-user first-launch state, which ADR-0005 removes. Help > Documentation already opens online AutoMap help (`OnlineDocumentationUri`, `.../automap/help`).

Add a Getting Started topic in the AutoMap help's "Welcome to ePublisher AutoMap" group. This docs-side topic belongs in epublisher-docs, not this repo; it links to the versioned trial guide, states where the installer puts materials, and explains Reset Evaluation Materials. Help ships online independently of the product build; track it here for conceptual coordination, not as Trac #2975 product work.

## Reset Evaluation Materials (required)

Reset Evaluation Materials is REQUIRED, not optional. It serves a second Windows user on a shared machine; a user whose install ran elevated under a different admin account; a silent-install user; a user skipped by condition (c); and anyone who deleted seeded jobs. Administrator Delete already removes jobs, so Reset is its natural counterpart that restores them.

Place the action in Preferences > General > Miscellaneous (`PrefEditorPanel.resx:292`). Adapt captions from Express `Redstone/UserInterface/Dialogs/ApplicationPrefDialog.*.resx` (de/fr/ja exist for Express; add them for AutoMap), plus a new confirmation prompt translated into German, French, and Japanese.

Reset runs as the current user into that user's Documents, and refuses while a seeded job is running. It deletes ONLY `<root>\Evaluation` and the three seeded job folders under `<root>\Jobs`, removing the folders directly rather than through `JobManager.DeleteJob`, which also deletes the job's scheduled task (`Automap/Core/JobManager.cs:389-422`); it never deletes Output, Staging, or any other job. It then re-extracts, verifies sentinels, re-runs the destination rewrite, and reloads the job list the same way a Jobs-folder change does (`JobManager.SetJobDirectory(AutomapUIPrefs.JobDir)` plus a grid refresh, `JobsForm.cs:2065-2069`), so the restored jobs appear without a restart. Conditions (a) to (c) do not apply because this is an explicit request. Condition (d) still applies in default-root mode: when `JobDir` is not the current user's product-default Jobs folder, restored jobs would land where the Administrator does not look, so Reset shows a message naming the current Jobs folder and the default and stops. Workspace mode has no such limit because the trial workspace registers its own jobs root. Scheduled tasks stay valid because job paths do not change. Reset never opens a browser.

In workspace mode, Reset targets the running build's `<root>` and re-registers the workspace if it was removed. Default-root materials seeded by an earlier build are left alone.

Express Reset (`Publish/Redstone/RedstoneApplication.cs:396-468`, button handler `ApplicationPrefDialog.cs:749-760`) deletes and re-extracts without a prompt. AutoMap adds the prompt and narrower scope because AutoMap job folders are user-editable in a way Express evaluation folders are not.

## Licensing note

Evaluation Contract IDs must include the AutoMap component (application ID 21). AutoMap does not reuse Express `.licinfo`. The user enters a Contract ID in AutoMap LicensingInfoForm during installer `--register` or through Help > License Keys (`Automap/AutomapUI/AutomapUI.cs:151-171`; `Automap/AutomapUI/UI/JobsForm.cs:2008-2013`).

Seeding, the Finish-page link, and Reset are not license-gated. The evaluation engine limits output to 8 generated documents, applies a Ghostscript-image watermark, and blocks XSL exec. Current seeded jobs are within the generation cap: Quantum Sync Help contains 1 Document element, Quantum Sync Release Notes contains 1, and Quantum Sync Site Shell contains 0 (the intended zero-document shell job).

These engine-level limits refine, rather than reverse, the research note's "Gap 2 CLOSED" conclusion. That finding concerned the absence of a format-level watermark call in shipped transforms. The engine's Ghostscript watermark and generation cap are a separate, narrower mechanism; do not claim that trial output is wholly unconstrained.

## Acceptance tests

Run these checks on a clean Windows machine with no WebWorks products installed. Use an evaluation Contract ID that includes AutoMap. Unless noted, `<root>` means the selected extraction root for the installing user.

1. Interactive install: confirm `C:\Program Files\WebWorks\ePublisher\2026.1\ePublisher AutoMap\Evaluation\Exp_AutoMap.wez` exists. Confirm archive root entries are `Evaluation/` and `Jobs/`, with no wrapper folder.
2. Before ever launching Administrator, confirm the installing user's `<root>` already holds the exact extracted tree. Each seeded .waj has an absolute Folder destination under `<root>\Output\<name>`; Project and Document paths stay relative and begin `..\..\Evaluation\`.
3. Confirm AutoMap Finish page shows "Open the AutoMap Trial Guide" and opens the correct versioned URL. Confirm Express and Designer Finish pages are unchanged.
4. First Administrator launch: three seeded jobs list without import; no browser opens; nothing extracts at launch because installation already seeded it.
5. Run each seeded job and confirm exit code 0 and `<root>\Output\<name>\index.html`; Explore Output opens it.
6. Repair or reinstall over existing materials: edit a seeded .waj first. Confirm the edit survives and nothing is overwritten.
7. Upgrade on a machine whose Jobs folder already holds a real job, or is relocated: confirm no trial materials are added.
8. Silent install (`/S`), including as SYSTEM: confirm no materials appear in any profile and no Finish page is shown.
9. CLI and scheduled-task runs never extract: run WebWorks.Automap.exe against a job and run a scheduled task; confirm no new Evaluation folder appears anywhere.
10. Second Windows account, with no Jobs folder preference stored (condition (d)): first Administrator launch shows no seeded jobs. Preferences > Reset Evaluation Materials prompts; cancel changes nothing. Confirm Reset seeds that account's own `<root>`, jobs appear without restart, and no browser opens.
11. On installing account, delete a seeded job via Delete, then Reset. Confirm it returns; Output, Staging, other jobs, and existing task for "Quantum Sync Release Notes" are untouched, and the task still runs the restored job. Start Reset while a seeded job is running and confirm it refuses.
12. Default-root mode with the Jobs folder preference pointing elsewhere: Reset shows a message naming the current Jobs folder and changes nothing.
13. Uninstall: confirm Program Files payload is removed and Documents is left alone.
14. German, French, and Japanese UIs: folder names remain the same literals; Reset caption, confirmation prompt, and Finish-page link text are translated.
15. Workspace mode only: after install, "Quantum Sync Trial" is registered for installing user. On a fresh machine Default job list is empty; switching to "Quantum Sync Trial" lists the three jobs.
16. Packaging: `python scripts/sync_variant_stationery.py --check` exits 0; `scripts/rehearse_seeded_jobs.ps1` and `scripts/stage_seeded_jobs.py` agree with extracted paths and rewritten destinations.
17. Docs: AutoMap help Getting Started topic is live and links to the versioned trial guide.

## Trac ticket #2975

Filed 2026-09-23 (https://factory.webworks.com/ePublisher_Platform/ticket/2975; enhancement, component Evaluation, milestone 2026.1, priority major) with the original first-launch design. The revised description below replaces it and should be applied via a ticket comment linking Trac #2919 and ADR-0005 (docs/adr/0005-install-time-evaluation-seeding.md).

The wiki markup below follows `trunk: .claude/commands/trac/create-ticket.md` (the recipe lives in the trunk working copy, not in this repo):

Summary: AutoMap - Seed evaluation materials at install time and link the trial guide from the installer

'''Goal:''' Make the AutoMap trial self-contained: ship an Evaluation archive in the AutoMap installer, seed materials during interactive installation, link to the online trial guide from the Finish page, and provide a required reset action.

'''Context:''' AutoMap has no evaluation payload or trial guide entry point today, and the published AutoMap trial guide (https://static.webworks.com/docs/epublisher/2026.1/automap/trial/) assumes seeded jobs already exist. Archive Exp_AutoMap.wez contains Quantum Sync Stationery, Quantum Sync Midnight Stationery, Quantum Sync source docs, and three seeded publishing jobs (1,083 files). It is generated by epublisher-express-trial and staged, unversioned, at products/AutoMap/Evaluation/ beside README.md. The full handoff spec with trunk anchors, payload manifest, and acceptance checks is docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec.md in quadralay/epublisher-express-trial (GitHub #37). The design follows docs/adr/0005-install-time-evaluation-seeding.md.

'''Acceptance Criteria:'''
 * Installer manifests install Exp_AutoMap.wez beside AutoMap Help; collector.py regenerates file lists and uninstall removes payload while leaving Documents alone.
 * Interactive --register seeds only when the Evaluation folder and the three seeded job folders are absent and, in default-root mode, the Jobs folder holds no jobs and the Jobs folder preference is the product default; extracts into the single <root> so Evaluation and Jobs are siblings, verifies sentinels, then rewrites Folder destinations. CLI and scheduled-task runs never seed.
 * AutoMap-only Finish-page link opens the versioned trial guide; text is translated in all four installer languages. Express and Designer Finish pages are unchanged.
 * Required Reset prompts, refuses while a seeded job is running, deletes only Evaluation and the three seeded job folders (directly, so their scheduled tasks survive), then extracts, verifies, rewrites and reloads the job list without touching Output, Staging or other jobs. In default-root mode it stops with a message when the Jobs folder preference points elsewhere.
 * Extraction root is one parameter; workspace mode is available when #2919 ships in the same build. Never migrate seeded jobs between roots.
 * Each seeded job runs with exit 0. Uninstall leaves Documents alone. Literal folder names remain the same in localized UIs.
 * AutoMap help Getting Started topic links to the versioned trial guide and explains seeded materials and Reset.

'''Technical notes:''' Add one public AutomapApplication method, shared by --register and Reset, that wraps the protected PublisherApplication.ExtractEvaluationWEZ (Publish/Core/PublisherApplication.cs:391-425), and verify sentinels because the helper swallows errors. The Administrator has no Jobs-folder watcher, so Reset reloads the job list itself (JobsForm.cs:2065-2069). DefaultDirectoriesCreated is not usable for gating: --register returns without disposing the app, so its dirty preference is not flushed there. Use scripts/stage_seeded_jobs.py and scripts/rehearse_seeded_jobs.ps1 for destination rewriting and rehearsal. Full spec: docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec.md in quadralay/epublisher-express-trial.

Release note addition, modeled on products/common/resources/readme.html:804-806:

{{{
<li id="wwli202975" class="UList_Item" value="1">
  <div class="UList_Paragraph"><a name="p202975">Seeded the AutoMap Trial evaluation materials during installation and added a link to the trial guide on the installer's Finish page (EPUB2975).</a></div>
</li>
}}}
