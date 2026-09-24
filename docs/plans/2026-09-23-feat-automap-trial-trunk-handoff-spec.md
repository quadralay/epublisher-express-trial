---
title: "feat: AutoMap Trial trunk handoff spec (installer payload, first-launch extraction, trial guide)"
type: feat
status: draft
date: 2026-09-23
origin: docs/research/automap-trial-features.md
---

# AutoMap Trial trunk handoff spec

## Overview

### Goal

Implement the product-side work that makes the AutoMap evaluation self-contained: package one Evaluation archive in the AutoMap installer, extract it for each Windows user's first interactive Administrator launch, open the versioned trial guide once, and provide a persistent Help-menu link. An optional reset action restores only these materials. This is a trunk implementation handoff; no product source is changed by this document.

### Template and design

Express and Designer already package .wez evaluation archives in their installers and extract the contents under a user's Documents folder on first launch. Designer also uses a protected browser-open pattern with HTTPS, the product version directory, UseShellExecute, and a try/catch. See docs/research/automap-trial-features.md, "Gap 7 informed" and "No evaluation seeding or trial-URL exists in AutoMap today". The AutoMap implementation reuses those patterns where their scope fits, with a per-user Administrator hook because AutoMap's existing one-shot guard is machine-wide.

The primary evaluation path and product independence are recorded in docs/adr/0001-automap-primary-evaluation-path.md. The on-disk contract is docs/agents/extraction-layout.md; seeded job behavior and rehearsal evidence are in docs/agents/seeded-jobs.md. Destination rewriting follows docs/adr/0004-seeded-job-folder-destinations.md and scripts/stage_seeded_jobs.py.

### What already exists (verified against trunk)

| Capability | Existing source or state | Handoff consequence |
|---|---|---|
| AutoMap Help archive | Express template at Express paths.json 142-144; AutoMap Help entry at x64 paths.json 149-151, x86 paths_x86.json 125-127 | Add Evaluation entries alongside Help. |
| Installer file list | AutoMap install_files.nsh Help block at 393-394 | This is a generated-output anchor only; edit paths.json, not the .nsh. |
| Evaluation extraction | PublisherApplication.ExtractEvaluationWEZ at 391-425 | Reuse the protected helper; failures are silently swallowed. |
| Startup hooks | AutomapApplication.OnInitializePreferences at 463-474; Administrator setup at AutomapUI.cs 58-71 and `new JobsForm()` at 77 | Use Administrator startup and a new per-user flag stored under the user's LocalAppData (not AdminUI.prefs). |
| Browser pattern | Designer's Program.cs 222-233 | Mirror its HTTPS, version, UseShellExecute and empty catch shape. |
| Help menu | JobsForm.cs 363-370 and handler cases 2008-2056 | Add Trial Guide after Release Notes and before Technical Support. |

All trunk references below use paths relative to `C:\Repo\ePublisher_debug\trunk\dev\source\windows\dotnet\WebWorks\` unless a path starts with `products/`, `docs/`, or another stated root. Line numbers are current verified anchors, not a claim that adjacent generated files should be edited by hand.

## Installer Evaluation payload

### Archive contract

Create a single plain ZIP-format .wez archive named `Exp_AutoMap.wez`, using 7-Zip `-tzip -mx=9`, from the CONTENTS of `latest/local-trial-projects/WebWorks ePublisher AutoMap/`. Do not add a wrapping directory. The root entries are `Evaluation/` and `Jobs/`. The packaging command is added to `/package-trials`; its destination is `SVN_LOCAL_PATH/products/AutoMap/Evaluation/Exp_AutoMap.wez`, beside a README.md, matching the existing `products/Express/Evaluation/` pattern.

The archive contains 1,083 files and 21,379,809 uncompressed bytes. The prebuilt path manifest is [docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec-manifest.txt](2026-09-23-feat-automap-trial-trunk-handoff-spec-manifest.txt); it lists every archive member relative to the mirror root. Do not create the archive from `git ls-files` or any other tracked-file-only list.

| Archive subtree | Files | Contents |
|---|---:|---|
| Evaluation/Quantum Sync Stationery/ | 535 | Stationery package, including its generated snapshots and baseline. |
| Evaluation/Quantum Sync Midnight Stationery/ | 535 | Variant package, including its generated snapshots and baseline. |
| Evaluation/Quantum Sync Source Docs/ | 10 | Book, Release Notes, topics, and architecture image. |
| Jobs/ | 3 | One .waj per seeded job. |
| Total | 1,083 | 21,379,809 bytes uncompressed. |

The 521 files under each `Formats/WebWorks Reverb 2.0.base/` and `Formats/PDF - XSL-FO.base/` tree are verbatim copies of the shipped format packages; preserve them in the ZIP but do not enumerate those files here. Each Stationery's other 14 files are:

- `Quantum Sync Stationery.wxsp` or `Quantum Sync Midnight Stationery.wxsp` and the matching `.manifest`.
- `Files/favicon.png`, `Files/footer-logo.png`, `Files/footer-logo.svg`, `Files/og.png`, `Files/pdf-cover.png`, and `Files/toolbar-logo.svg`.
- `Settings/PDF/schema.json`, `Settings/PDF/settings.json`, `Settings/Web Help/schema.json`, and `Settings/Web Help/settings.json`.
- `Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss` and `custom.scss`.

The source docs' 10 named files are `quantum-sync.md`, `release-notes.md`, `images/quantum-sync-architecture.svg`, and `topics/features.md`, `topics/getting-started.md`, `topics/glossary.md`, `topics/overview.md`, `topics/settings.md`, `topics/sync-modes.md`, and `topics/troubleshooting.md`. The jobs are `Quantum Sync Help/Quantum Sync Help.waj`, `Quantum Sync Release Notes/Quantum Sync Release Notes.waj`, and `Quantum Sync Site Shell/Quantum Sync Site Shell.waj`.

### Packaging source and generated content

Build the archive from the packaging machine's complete WORKING TREE, not from git alone. Git tracks only 20 of the 1,083 files: the three .waj files, two .wxsp files, ten source-doc files, and five variant chrome sources (three Files assets and two Sass partials). The other 1,063 files are regenerated: Quantum Sync Stationery is regenerated by Save as Stationery from the Designer Trial project (see docs/agents/release-migration.md); Quantum Sync Midnight Stationery is regenerated by `scripts/sync_variant_stationery.py` (ADR-0003).

Before packaging, run `python scripts/sync_variant_stationery.py --check` from the repo root and require exit code 0. This is a read-only drift check. The ignored Files/, Formats/, Settings/, and .manifest content must still be present in the working tree when 7-Zip runs. This is the same arrangement used by the Express Trial Stationery package: its Files/, Formats/, Settings/, and .manifest are gitignored too (`.gitignore` lines 9-12 for that package (line 8 is the Express project's manifest)).

The archive and a README.md now exist in the trunk working copy at `C:\Repo\ePublisher_debug\trunk\products\AutoMap\Evaluation\Exp_AutoMap.wez` (6,448,174 bytes, about 6.4 MB compressed); `7z l` reports 1083 files and 246 folders, matching the manifest's file count. The archive and its README.md are both unversioned in that SVN working copy (`svn status` shows a question mark for each), awaiting the maintainer's `svn add` and commit.

### Installer wiring

Add an `"ePublisher AutoMap\\Evaluation"` entry to both AutoMap installer manifests, shaped like the neighboring Help mapping and pointing its src at the working-tree `.wez` archive:

- `products/AutoMap/AutoMapInstaller/NSIS Installer/Include/paths.json` (x64), next to the Help key at lines 149-151.
- `products/AutoMap/AutoMapInstaller/NSIS Installer/Include/paths_x86.json`, next to the Help key at lines 125-127.

The Express template entry is at Express paths.json 142-144 (the research note's "143-145" drifted by one); copy its shape next to AutoMap's Help key. `collector.py` regenerates install_files.nsh and uninstall_files.nsh from these JSON files. Do not hand-edit generated .nsh output. AutoMap's own `install_files.nsh` lines 393-394 show today's Help SetOutPath/File pair and are the output sanity-check anchor.

No App.config change is needed. EvaluationFolder falls back to the executable directory plus `Evaluation`. The installed archive path is `C:\Program Files\WebWorks\ePublisher\2026.1\ePublisher AutoMap\Evaluation\Exp_AutoMap.wez`.

## First-launch extraction

### Required hook and guard

The issue originally anticipated putting extraction in `AutomapApplication.OnInitializePreferences` (trunk: `Automap/Core/AutomapApplication.cs:463-474`). That stub reads and flips `DefaultDirectoriesCreated` on `PublisherApplication.GetService<PublisherPreferences>()`. The storage is in the shared base class `Publish/Core/PublisherPrefences.cs:532-550` (the on-disk filename is spelled `Prefences`, with the missing e). AutoMap's constructor passes `base(true)` (`Automap/Core/AutomapApplication.cs:275-276`), which roots `Preferences.xml` under `%ProgramData%\WebWorks\ePublisher AutoMap\<version>\` (`AutomapApplication.cs:48`; `Publish/Core/PublisherPrefences.cs:619-621`), machine-wide; Express passes `base(false)` (`Publish/Redstone/RedstoneApplication.cs:566`), so its copy is per-user under `%LOCALAPPDATA%`. AutoMap's installer `--register` path constructs the application and flips the shared guard (`Automap/AutomapUI/AutomapUI.cs:151-171`) once per install, before any user's first Administrator launch.

Do not seed from `OnInitializePreferences`. It also runs for CLI and scheduled-task initialization, neither of which should perform browser or other interactive startup work. More importantly, the registration-time, machine-wide bit cannot identify each Windows user's first run. The minimal alternative is to extract there and accept install-time/single-user semantics, meaning only the user who ran `--register` gets the material. Reject that alternative because additional users on shared machines would miss the trial assets, and a silent or per-machine install would seed nobody's Documents.

Run extraction only in the interactive Administrator startup sequence in `Automap/AutomapUI/AutomapUI.cs`: after product-default Jobs and Staging directory creation in lines 58-71, and before `this.MainForm = new JobsForm()` at line 77. Gate the one-shot guide open with a new per-user flag, for example `TrialGuideOpened`, in a new per-user store. `AdminUI.prefs` is not per-user: `AutomapUIPrefs.Prefs` (`Automap/AutomapUI/AutomapUIPrefs.cs:56-60`) builds its path from `AutomapPreferences.ApplicationPreferencesDirectoryPath` (`Automap/Core/AutomapPreferences.cs:156-167`), which for `base(true)` is the same ProgramData folder as `Preferences.xml` (`Publish/Core/PublisherPrefences.cs:619-634, 771-772`); `LocalAppDataPathStore` (`Common/Preferences.cs:312`) is a plain file-backed store and its name does not imply LocalAppData.
Root the new file with the public static `PublisherPreferences.DetermineApplicationPreferencesRootPath(false, AutomapApplication.RELATIVE_APPLICATION_PREFERENCES_ROOT_PATH)` (`PublisherPrefences.cs:613`), without a version subfolder so the guide opens once per user rather than once per release (decision; the versioned alternative re-opens the guide after each upgrade). Create the file if absent and flush it immediately after setting the flag: `SetProperty` only marks the store dirty and it serializes on `Flush` (`Common/Preferences.cs:465-476`). Do not put the flag on shared `PublisherPreferences` or in `AdminUI.prefs`.

The extraction decision itself needs no flag: `<Documents>` is per-user, so the existence check below is already per-user. The flag governs only the one-time browser open.

On that user's first Administrator launch, when `<root>\Evaluation` and all three seeded job folders under `<root>\Jobs` are absent, call the inherited protected `ExtractEvaluationWEZ` (`Publish/Core/PublisherApplication.cs:391-425`, reachable from AutoMap) with the installed archive and `<root>` itself, the product folder, so that `Evaluation\` and `Jobs\` land as siblings. Extracting into `<root>\Evaluation` would produce `Evaluation\Evaluation\` and `Evaluation\Jobs\` and break every relative path.
Resolve `<root>` as `Environment.SpecialFolder.Personal` plus the fixed literal `WebWorks ePublisher AutoMap`, matching `Automap/Core/AutomapPreferences.cs:93-109`. If `Evaluation` or any seeded job folder already exists, skip extraction entirely and never overwrite or delete anything on first launch: `ZipFile.ExtractToDirectory` on .NET Framework throws on any pre-existing file, and because the helper swallows the exception a surviving `Jobs\Quantum Sync Help\Quantum Sync Help.waj` would abort the extraction silently part-way.

The helper reports nothing, so verify the result afterwards: the three seeded `.waj` files and `Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp` must exist. Only after that check rewrite the Folder destinations (below) and arm the one-time guide open. Set the per-user flag after the attempt in either case so the launch stays one-shot; Reset Evaluation Materials is the recovery for a failed or partial extraction. Upgrades do not re-extract because the existence check fails once the folders exist.

The helper's comment at 391-400 is load-bearing: reset/first-run callers choose when to clear; this plain extraction creates the destination only when absent, then extracts. It deliberately avoids delete-and-recreate because redirected Documents may be in OneDrive; deletion can leave an empty cloud placeholder, and the swallowed exception would leave no extracted files. Its catch block near the end of the method (about 420-424) is empty (`Silently fail!`). Match Express's actual behavior: swallow failures silently with a bare catch and no logging. Express's caller also uses bare catches; it does not log extraction failures today. Logging can be considered as a separate enhancement, but is not required for parity.

AutoMap's skip-if-Evaluation-exists rule is a deliberate departure from Express's literal `ResetEvaluationMaterials` first-run behavior (`Publish/Redstone/RedstoneApplication.cs:396-468`), which deletes and recreates existing extracted folders. AutoMap's machine-wide registration guard and per-user startup mean a second user's first launch may find content another user has customized. Never let that launch stomp it.

### Layout, localized folders, and relative paths

The tree below reproduces the contract in `docs/agents/extraction-layout.md`, "The layout on a trial user's machine". `<Documents>` is the Windows Personal known folder and may be redirected to OneDrive. Jobs, Staging, Evaluation, Output, and every child name shown are fixed literals, not localized resources.

```
<Documents>\WebWorks ePublisher AutoMap\            AutoMap product folder
+-- Jobs\                                            product-default Jobs folder (seeded jobs land here)
|   +-- Quantum Sync Help\Quantum Sync Help.waj
|   +-- Quantum Sync Release Notes\Quantum Sync Release Notes.waj
|   +-- Quantum Sync Site Shell\Quantum Sync Site Shell.waj
+-- Staging\                                         product-default Staging folder (untouched)
+-- Output\                                          seeded jobs and in-guide composition deploy here (Output\<job name>\, created by first run)
+-- Evaluation\                                      AutoMap evaluation materials
    +-- Quantum Sync Stationery\
    |   +-- Quantum Sync Stationery.wxsp
    |   +-- Quantum Sync Stationery.manifest
    |   +-- Files\
    |   +-- Formats\
    |   +-- Settings\
    +-- Quantum Sync Midnight Stationery\            variant Stationery (chrome-only re-skin)
    |   +-- Quantum Sync Midnight Stationery.wxsp
    |   +-- Quantum Sync Midnight Stationery.manifest
    |   +-- Files\
    |   +-- Formats\
    |   +-- Settings\
    +-- Quantum Sync Source Docs\
        +-- quantum-sync.md                          Quantum Sync book (includes topics/*.md)
        +-- topics\
        +-- images\
        +-- release-notes.md                          Release Notes document
```

Folder contract: job identity is folder name = .waj name = `<Job name>`; the Administrator scans Jobs live, so no import is needed. `Output\<name>` is created by the first run. The seeded jobs' Folder destinations deploy there; Staging remains the product-default folder and is not replaced or moved.

Relative-path rule: AutoMap resolves `<Project path>` and every `<Document path>` from the directory containing the .waj. Exactly two `..\` segments from `Jobs\<name>\<name>.waj` reach the product folder. Keep all project and document paths relative, with backslashes, and starting `..\..\Evaluation\`; never reference Express/Designer folders or climb above the product folder. Examples are `..\..\Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp`, `..\..\Evaluation\Quantum Sync Midnight Stationery\Quantum Sync Midnight Stationery.wxsp`, `..\..\Evaluation\Quantum Sync Source Docs\quantum-sync.md`, and the corresponding `release-notes.md` path.

Jobs and Evaluation must remain siblings under the AutoMap product folder. Extraction always targets the product-default Jobs folder. A `JobsDirectory` override set before the first Administrator launch is outside the trial's fresh-install scope; a user who relocates Jobs afterwards breaks the seeded jobs' relative paths, as with any relative-path job. A Stationery job stages under `Staging\<name>\Output\<Target>\`; the guide does not send users there.

#### Localized Documents folder names

| Segment | Varies? |
|---|---|
| `<Documents>` known folder | Display name is localized and the directory may redirect to OneDrive. Resolve with `Environment.SpecialFolder.Personal`. |
| `WebWorks ePublisher AutoMap`, `Jobs`, `Staging` | No; these are fixed AutoMap literals. |
| `Evaluation` and every descendant name | No; these are fixed evaluation-material contract names. |
| Express and Designer folders such as `ePublisher Express Projects` and `ePublisher Stationery` | Yes; those folders are localized and must not be used by AutoMap. |

Seeded jobs are unaffected by UI language because no job path contains a localized segment. First-launch extraction uses the same Personal known-folder lookup as Jobs and treats names below it as fixed literals; do not add language-specific folder resources. Guide and screenshot prose should call this "your Documents folder", note that Windows may display a localized name or redirect it into OneDrive, and prefer Administrator navigation (job list, job folder, Explore Output) over typed paths.

### Job destination rewrite

The repo .waj files carry a Folder destination Configuration Value of `..\..\Output\<name>`. After extraction, rewrite only each relative Folder destination value to an absolute `<root>\Output\<name>` value, where `<root>` is the AutoMap product folder. `Publish/Core/Deployment/FolderDeployTarget.cs:28` uses that value verbatim. The scheduler's working directory is System32, so leaving it relative is not reliable (ADR-0004; `docs/agents/seeded-jobs.md`, "Destination strategy").

Use `scripts/stage_seeded_jobs.py` as the reference implementation: identify inline `DeploySetting` elements with `Action="file"`, rewrite relative Configuration Value paths against the destination job directory, preserve absolute values, and leave XML Project and Document paths relative. This is exactly the path distinction required by the runtime. Scheduled tasks remain valid because the job and Evaluation paths do not change.

The repository's `scripts/rehearse_seeded_jobs.ps1` rehearses this extracted layout and job destination rewrite; `docs/agents/seeded-jobs.md`, "Rehearsal results", records the passing run. The rehearsal is evidence for the archive's content contract, not a replacement for the Windows installer acceptance checks below.

## Trial-guide URL auto-open and Help-menu item

The canonical URL is `https://static.webworks.com/docs/epublisher/{VersionDirectoryName}/automap/trial/`; for 2026.1 it is `https://static.webworks.com/docs/epublisher/2026.1/automap/trial/`. The versioned URL pattern is also recorded in `docs/agents/extraction-layout.md`, "The trial guide's URL".

After a verified first extraction, open the URL once for that Windows user, and do it from the Administrator's first-idle `LicensingHandler` (`Automap/AutomapUI/AutomapUI.cs:101-124`), after the license check completes, not from the constructor: `Application.Idle` fires only after `Application.Run`, so nothing modal precedes the constructor, but a constructor-time `Process.Start` would put the browser under the main window and any license dialog.
Extraction itself stays before `new JobsForm()`: `JobsForm.cs:129` calls `JobManager.SetJobDirectory`, whose `LoadAllJobs` scans the Jobs folder at construction (`Automap/Core/JobManager.cs:198-216`), so the seeded jobs appear without a restart. Mirror the Designer shape in `Publish/Publisher/Program.cs:222-233`: a ProcessStartInfo with the version-formatted HTTPS URL, `UseShellExecute = true`, `Process.Start` inside try/catch, empty catch. Do not copy Express's CommandLineHandler shape: its URL is hard-coded HTTP and it has no try/catch (`docs/research/automap-trial-features.md`, "Gap 7 informed"). Never open from CLI or scheduled-task initialization, and never when the extraction check failed or was skipped.

AutoMap has no Start Page and no existing trial guide item. Add a Help-menu ButtonTool named `Trial Guide` in `Automap/AutomapUI/UI/JobsForm.cs`, declared near the existing Help tools at lines 363-370. Place the menu item after Release Notes and before Technical Support (menu order: License Keys, Documentation, Release Notes, Technical Support, Update Center, WebWorks.com, About).
The handler switch (2008-2056) dispatches on tool keys, `"Contents"` for Documentation (2014) and `"HelpSearch"` for Release Notes (2037-2042; the comment there says the key is frozen because it is saved in the toolbar preferences file), so add a new key such as `"TrialGuide"` with its case beside `"HelpSearch"`. Captions for the existing tools come from `JobsForm.resx` (`resource.Caption17`, `Caption19`), so set the Trial Guide caption in code from the Core resource. Verify that a toolbar layout saved by an earlier build does not hide the newly added tool.

Caption it from Core resource `AtAGlance_EvaluationGuide`, whose English value is `Trial Guide for {0}` and whose de/fr/ja entries exist. Format it with the AutoMap ProductName resource (`WebWorks ePublisher AutoMap`) so the English caption is `Trial Guide for WebWorks ePublisher AutoMap`. Express formats the same resource with `VersionDirectoryName` (`RedstoneApplication.cs:303`), giving "Trial Guide for 2026.1"; the product-name choice here is deliberate, since AutoMap's menu carries no version elsewhere. Open the same URL with the same HTTPS, VersionDirectoryName, UseShellExecute, try/catch pattern as the automatic launch. Keep the item always enabled, regardless of license state.

The trial guide remains available from Help after the first-open has happened. The auto-open is one-shot per-user and follows successful first extraction; the menu action can be used any time. Express has no Help-menu Trial Guide item; its link is the Start Page "At a Glance" entry built in `Publish/Redstone/RedstoneApplication.cs:293-305` (caption `AtAGlance_EvaluationGuide`, `Publish/Core/Resources/strings.resx:310-311`), and that list is the standard one, shown only when `EvaluationOnly()` is false (`RedstoneApplication.cs:327-334`), so evaluation users never see it: an inversion AutoMap must not copy (the Trial Guide item is always visible).

## Reset Evaluation Materials

Add an optional reset button to Preferences > General > Miscellaneous. `Automap/AutomapUI/UI/PrefEditorPanel.resx` has that group's caption at line 292. Reuse the captions from Express `ApplicationPrefDialog.*.resx` where suitable, and add AutoMap UI resource strings for the confirmation prompt and result text.

Before reset, show a confirmation prompt. AutoMap's reset must delete only `<root>\Evaluation` and the three seeded job folders under `<root>\Jobs`: `Quantum Sync Help`, `Quantum Sync Release Notes`, and `Quantum Sync Site Shell`. Then re-extract and re-absolutize their Folder destinations. Never delete Output, Staging, or any other job folder. The prompt is required because a user may have reused a seeded job's name for their own work; explain that these three folders will be replaced.

Reset should use the same extraction and rewrite path as first launch. Scheduled tasks remain valid because the job file paths do not change. Reset does not touch the per-user flag and never opens the guide: it is a recovery action, not a new first launch. Express's reset deletes and recreates its evaluation folders (`Publish/Redstone/RedstoneApplication.cs:396-468`); AutoMap adds confirmation and a narrower deletion scope because job folders are user-editable.

## Licensing note

Evaluation Contract IDs must include the AutoMap component (application ID 21). AutoMap does not reuse Express's `.licinfo`. The user enters a Contract ID in AutoMap's LicensingInfoForm during installer `--register` or through Help > License Keys (`Automap/AutomapUI/AutomapUI.cs:151-171`; `Automap/AutomapUI/UI/JobsForm.cs:2008-2013`).

Extraction, the automatic browser open, and the Help-menu item are not license-gated. The evaluation engine limits output to 8 generated documents, applies a Ghostscript-image watermark, and blocks XSL exec. Current seeded jobs are within the generation cap: Quantum Sync Help contains 1 Document element, Quantum Sync Release Notes contains 1, and Quantum Sync Site Shell contains 0 (the intended zero-document shell job).

These engine-level evaluation limits refine, rather than reverse, the research note's "Gap 2 CLOSED" conclusion. That finding was about the absence of a format-level watermark call in shipped transforms. The engine's Ghostscript watermark and generation cap are a separate, narrower mechanism; do not claim that trial output is wholly unconstrained.

## Acceptance tests

Run these checks on a clean Windows machine with no WebWorks products installed. Use an evaluation Contract ID that includes AutoMap. For all paths below, `<root>` means the user's Documents known folder plus `WebWorks ePublisher AutoMap`.

1. Install AutoMap and confirm `C:\Program Files\WebWorks\ePublisher\2026.1\ePublisher AutoMap\Evaluation\Exp_AutoMap.wez` exists. Confirm archive top-level entries are Evaluation/ and Jobs/ with no wrapper folder.
2. Launch Administrator as a user who has not run it before. Confirm the exact tree above is created under `<root>`; Jobs contains the three named job folders, Staging exists, and Evaluation contains both Stationeries and Source Docs.
3. Confirm the Administrator job list displays Quantum Sync Help, Quantum Sync Release Notes, and Quantum Sync Site Shell without an import step.
4. Inspect each extracted .waj and confirm its Folder destination Configuration Value is absolute under `<root>\Output\<name>`. Confirm Project and Document paths remain relative and begin `..\..\Evaluation\`.
5. Confirm the default browser opens the versioned AutoMap trial guide exactly once after successful first extraction. Relaunch Administrator and confirm no second automatic open. The open happens after any license dialog has closed, with the browser in front of the Administrator window.
6. Confirm Help > Trial Guide is present, always enabled, and opens the same versioned URL. Verify the caption resource has de/fr/ja translations and uses the product name.
7. Run each of the three seeded jobs in Administrator. Each run must exit 0 and produce `<root>\Output\<name>\index.html`. Explore Output must open the destination for the selected job.
8. From a second Windows account, run `WebWorks.Automap.exe` against any job file (for example a copy of a seeded `.waj` placed in that account's Documents). Confirm it does not extract evaluation materials or open a browser. Then launch that account's Administrator for the first time and confirm it does extract its own materials and opens the guide once.
9. In Preferences, choose Reset Evaluation Materials, cancel once and confirm nothing changes; confirm again and verify the prompt, scoped deletion, extraction, and destination rewrite. Confirm Output, Staging, and unrelated jobs remain untouched and no browser auto-open occurs.
10. Uninstall AutoMap. Confirm the Program Files payload is removed and Documents evaluation materials are left intact.
11. Repeat the folder-name check under English, German, French, and Japanese UI settings. The localized Documents known-folder display may vary; the product folder and children remain the same literal names.
12. Before packaging, run `python scripts/sync_variant_stationery.py --check` and require exit 0. The existing `scripts/rehearse_seeded_jobs.ps1` rehearsal and `python scripts/stage_seeded_jobs.py` reference implementation should continue to agree with the extracted paths and rewritten destination values.
13. On a further fresh account, hand-stage the archive contents into `<root>` before the first launch, then launch Administrator: nothing is deleted or overwritten, the seeded jobs list, and no browser opens.

## Trac ticket draft

Filed 2026-09-23 as Trac #2975 (https://factory.webworks.com/ePublisher_Platform/ticket/2975): type enhancement, component Evaluation, milestone 2026.1, priority major, following `trunk: .claude/commands/trac/create-ticket.md` (Trac wiki markup, ASCII only, bold labels). The description below is the filed text, kept here so the plan and the ticket can be diffed.

Summary: AutoMap - Seed evaluation materials and open the trial guide on first Administrator launch

'''Goal:''' Make the AutoMap trial self-contained: ship an Evaluation archive in the AutoMap installer, extract it into each Windows user's Documents folder on that user's first interactive Administrator launch, open the online trial guide once, and add a permanent Help menu link to it.

'''Context:''' AutoMap has no evaluation payload and no trial guide entry point today, and the published AutoMap trial guide (https://static.webworks.com/docs/epublisher/2026.1/automap/trial/) assumes seeded jobs are already in the job list. The archive Exp_AutoMap.wez (Quantum Sync Stationery, Quantum Sync Midnight Stationery, the Quantum Sync source documents and three seeded publishing jobs; 1,083 files) is generated by the epublisher-express-trial repo and is staged, unversioned, at products/AutoMap/Evaluation/ next to a README.md. The full handoff spec, with trunk source anchors, a payload manifest and acceptance tests, is docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec.md in that repo (quadralay/epublisher-express-trial, GitHub #37).

Express is the template (installer paths.json entry, ExtractEvaluationWEZ on first launch, trial URL open), with two differences forced by AutoMap's own code: the shared DefaultDirectoriesCreated guard is machine-wide (AutomapApplication constructs with base(true), so Preferences.xml is under ProgramData) and is flipped by the installer's --register run, and AdminUI.prefs lives in that same ProgramData folder. Neither can mark a per-user first launch, so the hook and the flag differ from Express.

'''Acceptance Criteria:'''
 * paths.json and paths_x86.json carry an "ePublisher AutoMap\\Evaluation" entry that installs Exp_AutoMap.wez beside the Help archive (collector.py regenerates the .nsh files); uninstall removes it and leaves the user's Documents alone.
 * On a user's first interactive Administrator launch (AutomapUI.cs, after the Jobs and Staging folders are created and before new JobsForm()), when Documents\WebWorks ePublisher AutoMap\Evaluation and the three seeded job folders are all absent, the archive is extracted into the product folder itself so Evaluation\ and Jobs\ land as siblings, and each seeded .waj's relative Folder destination (..\..\Output\<name>) is rewritten to the absolute <root>\Output\<name>. Project and document paths stay relative (..\..\Evaluation\...).
 * A per-user one-shot flag under the user's LocalAppData (DetermineApplicationPreferencesRootPath(false, ...) plus the version directory) governs the one-time guide open; it is not stored in Preferences.xml or AdminUI.prefs. CLI and scheduled-task runs never extract or open a browser. A second Windows account gets its own extraction on its own first launch.
 * After a verified extraction (the three .waj files and Quantum Sync Stationery.wxsp exist afterwards; ExtractEvaluationWEZ swallows failures), https://static.webworks.com/docs/epublisher/{VersionDirectoryName}/automap/trial/ opens once, from the first-idle handler after licensing, using Designer's ProcessStartInfo pattern (HTTPS, UseShellExecute, try/catch).
 * The Help menu gets "Trial Guide for WebWorks ePublisher AutoMap" (Core resource AtAGlance_EvaluationGuide, de/fr/ja present) between Release Notes and Technical Support, always enabled regardless of license state, opening the same URL.
 * Optional parity: Preferences > General > Miscellaneous gets Reset Evaluation Materials, which prompts first, deletes only Evaluation and the three seeded job folders, re-extracts, re-rewrites the destinations, and does not re-open the guide.
 * On a clean machine with an evaluation Contract ID that includes AutoMap (application ID 21), the three seeded jobs run from the Administrator with exit 0 and Explore Output opens <root>\Output\<name>\index.html; German, French and Japanese UIs use the same literal folder names.

'''Technical notes:''' Reuse PublisherApplication.ExtractEvaluationWEZ (Publish/Core/PublisherApplication.cs:391-425). The trial repo's scripts/stage_seeded_jobs.py is the reference implementation of the destination rewrite and scripts/rehearse_seeded_jobs.ps1 exercises the extracted layout end to end. Suggested release note: Seeded the AutoMap Trial evaluation materials and opened the trial guide on first Administrator launch.

One deviation from the filed text: the plan above roots the per-user flag without a version subfolder (the ticket says 'plus the version directory'); the plan is authoritative and the ticket will be commented when implementation starts.

Release note addition, modeled on products/common/resources/readme.html:796:

{{{
<div class="UList_Paragraph"><a name="pEPUB2975">Seeded the AutoMap Trial evaluation materials and opened the trial guide on first Administrator launch (EPUB2975).</a></div>
}}}
