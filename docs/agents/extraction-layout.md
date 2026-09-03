# Extraction-layout contract (AutoMap evaluation materials)

Where every piece of AutoMap evaluation material lands on a trial user's machine, and the relative-path rule seeded jobs are authored against. The AutoMap installer carries these materials and AutoMap Administrator extracts them on first launch (ADR-0001); the product-side work that realizes this layout is specified in the trunk handoff spec. Everything downstream — the seeded jobs, the variant Stationery, the trial guide and its screenshots, the handoff spec — is written against this document.

Vocabulary follows `CONTEXT.md` (evaluation materials, seeded job, publishing job, shell, chrome). Naming follows ADR-0002.

## The layout on a trial user's machine

Everything lives under the **AutoMap product folder**, `<Documents>\WebWorks ePublisher AutoMap\`, next to the product-default Jobs and Staging folders:

```
<Documents>\WebWorks ePublisher AutoMap\            AutoMap product folder
├── Jobs\                                            product-default Jobs folder (seeded jobs land here)
│   ├── Quantum Sync Help\Quantum Sync Help.waj
│   ├── Quantum Sync Release Notes\Quantum Sync Release Notes.waj
│   └── Quantum Sync Site Shell\Quantum Sync Site Shell.waj
├── Staging\                                         product-default Staging folder (untouched)
├── Output\                                          seeded jobs and the in-guide composition deploy here (Output\<job name>\, created by the first run)
└── Evaluation\                                      AutoMap evaluation materials
    ├── Quantum Sync Stationery\
    │   ├── Quantum Sync Stationery.wxsp
    │   ├── Quantum Sync Stationery.manifest
    │   ├── Files\
    │   ├── Formats\
    │   └── Settings\
    ├── Quantum Sync Midnight Stationery\            variant Stationery (chrome-only re-skin)
    │   └── Quantum Sync Midnight Stationery.wxsp    (+ .manifest, Files\, Formats\, Settings\)
    └── Quantum Sync Source Docs\
        ├── quantum-sync.md                          the Quantum Sync book (includes topics\*.md)
        ├── topics\
        ├── images\
        └── release-notes.md                         the Release Notes document
```

| Material | Folder under the product folder | Delivered by |
|----------|----------------------------------|--------------|
| Quantum Sync Stationery | `Evaluation\Quantum Sync Stationery\` | #29 (this contract) |
| Variant Stationery — **Quantum Sync Midnight Stationery** (ADR-0003): Quantum Sync Stationery with midnight chrome and identical style mappings | `Evaluation\Quantum Sync Midnight Stationery\` | #31 |
| Quantum Sync book (source docs) | `Evaluation\Quantum Sync Source Docs\` | #29 |
| Release Notes document | `Evaluation\Quantum Sync Source Docs\release-notes.md` | #30 |
| Output folder | `Output\` | Created at first run by each job's Folder destination; #32 |
| Seeded jobs: Quantum Sync Help, Quantum Sync Release Notes, Quantum Sync Site Shell | `Jobs\<name>\<name>.waj` | #32 |
| Composition job Quantum Sync Site | Created by the trial user in-guide; nothing is seeded | #33 |

Job identity is the folder name: `Jobs\<name>\<name>.waj`, where `<name>` is also the `name` attribute of the `<Job>` element. The Administrator scans the Jobs folder live, so a seeded job appears in the job list as soon as its `.waj` lands there; there is no import step.

## Why the AutoMap product folder

The choice is driven by localization. Facts from the ePublisher dev repo (`trunk` = `%EPUBLISHER_DEV_PATH%`, typically `C:\Repo\ePublisher_debug\trunk`):

- The product-default Jobs and Staging folders are hard-coded, non-localized literals: `Path.Combine(<Documents>, @"WebWorks ePublisher AutoMap\Jobs")` and `...\Staging` (`trunk: dev/source/windows/dotnet/WebWorks/Automap/Core/AutomapPreferences.cs`, `DefaultJobsDirectory` / `DefaultStagingDirectory`). `<Documents>` is `Environment.SpecialFolder.Personal`, which follows Windows folder redirection (OneDrive included).
- The AutoMap product name resource is the same string in every language file (`trunk: .../Automap/Core/Resources/SpecialStrings*.resx`, `ProductName` = `WebWorks ePublisher AutoMap` in en/de/fr/ja).
- The Express and Designer evaluation folders are **localized** resource strings: `ePublisher Express Projects` is `ePublisher Express-Projekte` / `Projets ePublisher Express` / `ePublisher Express プロジェクト` (`trunk: .../Publish/Redstone/Resources/SpecialStrings.{de,fr,ja}.resx`, `ProjectsFolder`), and `ePublisher Stationery` is `ePublisher Briefpapier` / `Papeterie ePublisher` / `ePublisher ステーショナリー` (`trunk: .../Publish/Core/Resources/strings.{de,fr,ja}.resx`, `StationeryFolder`). Only the leaf names Express extracts (`ePublisher Express Trial Project`, `ePublisher Express Trial Stationery`) are fixed English literals (`trunk: .../Publish/Redstone/RedstoneApplication.cs`, `ResetEvaluationMaterials`).

Consequences:

- A seeded job authored with `..\..\Evaluation\...` paths never spells a localized folder name, so one set of job files works on every Windows UI language and under OneDrive redirection.
- The evaluation is self-contained (ADR-0001): nothing lands in a folder the Express or Designer installers own, so installing those products alongside neither collides with nor is required by the AutoMap trial.
- `Evaluation` matches the product code's naming for this material (the installer payload folder is also `Evaluation`).

Rejected alternative: placing the Stationery in Express's `<Documents>\ePublisher Stationery\` folder. It reads naturally on an English machine, but a seeded job would have to climb to `<Documents>` and descend into a localized folder name — either breaking on de/fr/ja, or forcing the extraction to create an English-named folder beside localized siblings.

## Relative-path rule for seeded jobs

AutoMap resolves a job's `<Project path>` and every `<Document path>` relative to the folder containing the `.waj` (`trunk: .../Automap/Core/JobInfo.cs`, `ProjectPath` setter; `.../Automap/Core/DocumentNode.cs`, `Path`). From `Jobs\<name>\<name>.waj`, exactly two `..\` segments reach the product folder, and everything else is under `Evaluation\`:

| Reference | Path as written in the `.waj` |
|-----------|-------------------------------|
| Quantum Sync Stationery (job origin) | `..\..\Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp` |
| Variant Stationery (re-skin step) | `..\..\Evaluation\Quantum Sync Midnight Stationery\Quantum Sync Midnight Stationery.wxsp` |
| The Quantum Sync book | `..\..\Evaluation\Quantum Sync Source Docs\quantum-sync.md` |
| The Release Notes document | `..\..\Evaluation\Quantum Sync Source Docs\release-notes.md` |

Rules:

1. Every `<Project path>` and `<Document path>` is relative, uses backslashes, and starts with exactly `..\..\Evaluation\`. Never absolute; never climb above the product folder; never reference an Express or Designer folder.
2. The job folder name, the `.waj` file name, and the `<Job name="...">` attribute are the same string.
3. The invariant the paths depend on is that **`Jobs` and `Evaluation` are siblings under the product folder**. Extraction targets the product-default Jobs folder; the handoff spec decides how to handle a surviving relocated Jobs-folder preference (only possible after a reinstall) while keeping the siblings invariant. A user who relocates the Jobs folder afterwards breaks seeded jobs exactly as they would break any relative-path job; the guide does not cover that case.
4. Stationery-based jobs build in the Staging folder (`Staging\<name>\Output\<Target>\`); the guide never sends a trial user there. Each seeded job deploys through a local Folder destination written as `..\..\Output\<name>` in the repo `.waj`; extraction absolutizes that value under the AutoMap product folder. See `docs/agents/seeded-jobs.md` and ADR-0004.

## Localized Documents folder names

What varies by Windows UI language or configuration, and what does not:

| Segment | Varies? |
|---------|---------|
| `<Documents>` (the Windows Documents known folder) | Display name is localized; the folder may be redirected to OneDrive. AutoMap resolves it via `Environment.SpecialFolder.Personal`. |
| `WebWorks ePublisher AutoMap`, `Jobs`, `Staging` | Fixed literals in AutoMap. |
| `Evaluation` and every folder and file name under it, and every seeded job folder name | Fixed literals defined by this contract, not resource strings. |
| `ePublisher Express Projects`, `ePublisher Stationery`, `ePublisher Designer Projects` | Localized. The AutoMap evaluation never places anything there and never references them. |

How each consumer handles this:

- **Seeded jobs** are unaffected: no path in a seeded job contains a localized segment.
- **First-launch extraction (handoff spec)** resolves `<Documents>` the way AutoMap already resolves the Jobs folder and treats every name below it as a fixed literal — no new resource strings, no per-language folder names.
- **Guide and screenshot prose** writes locations as `Documents\WebWorks ePublisher AutoMap\...`, introduces `Documents` once as "your Documents folder" with a note that Windows may show it under a localized name or inside OneDrive, and prefers the Administrator's own navigation (the job list, the job's folder, Explore Output) over typed paths. The guide never names an Express or Designer folder.

## The repo mirror

`latest/local-trial-projects/WebWorks ePublisher AutoMap/` mirrors the product folder one-to-one, the same way `ePublisher Express Projects/`, `ePublisher Designer Projects/`, and `ePublisher Stationery/` mirror the Express and Designer extraction folders:

```
latest/local-trial-projects/WebWorks ePublisher AutoMap/
├── Evaluation/
│   ├── Quantum Sync Stationery/           tracked: Quantum Sync Stationery.wxsp only
│   ├── Quantum Sync Midnight Stationery/  tracked: the .wxsp plus its chrome — three Files/ assets and Formats/WebWorks Reverb 2.0/Pages/sass/
│   └── Quantum Sync Source Docs/          tracked in full
└── Jobs/                                  tracked in full: <name>/<name>.waj (docs/agents/seeded-jobs.md)
```

- The `.gitignore` globs `Evaluation/*/Files/*`, `Evaluation/*/Formats/*`, `Evaluation/*/Settings/*`, and `Evaluation/*/*.manifest`, so any Stationery folder placed under `Evaluation/` follows the same track-only-the-`.wxsp` rule as the Express Trial Stationery. The ignored files must still exist on disk for builds and packaging; regenerate them per `docs/agents/release-migration.md` if they go missing.
- Quantum Sync Midnight Stationery is the exception (ADR-0003): its chrome — `toolbar-logo.svg`, `footer-logo.svg` and `favicon.png` under `Files/`, and everything under `Formats/WebWorks Reverb 2.0/Pages/sass/` — is its design source and is tracked through `.gitignore` negations. Everything else in its folder, the PDF cover and Open Graph image included, is regenerated from Quantum Sync Stationery with `python scripts/sync_variant_stationery.py`; `--check` reports drift without writing.
- Because every seeded-job path is relative to the job file, the seeded state can be hand-staged on any machine by copying the **contents** of this folder into `<Documents>\WebWorks ePublisher AutoMap\` (existing jobs and the Staging folder are unaffected). This is how the screenshots are captured (#35) and how a maintainer verifies the materials before the product-side extraction ships.
- Packaging the materials into the installer payload is defined with the handoff spec (#37) and added to `docs/agents/trial-project-workflow.md` then.

### Verification recipe (the end-to-end seam)

Run from any location; the layout is relocatable. Rehearse the seeded jobs and the composition end-to-end with `scripts/rehearse_seeded_jobs.ps1`. Use the `automap` skill's scripts (`<automap-skill>` is the skill's base directory; the build wrapper is `Invoke-Automap.ps1` in skill 3.9 and later, `automap-wrapper.sh --all-targets` in earlier releases).

```bash
# 1. Stage a mock of the extracted tree on a short path (the Stationery's deepest
#    files push a long temp path past 260 characters). Q: must be free.
subst Q: "<some scratch folder>"
mkdir -p "/q/WebWorks ePublisher AutoMap/Jobs/Quantum Sync Help" "/q/WebWorks ePublisher AutoMap/Staging"
(cd "latest/local-trial-projects/WebWorks ePublisher AutoMap" && tar cf - Evaluation) | (cd "/q/WebWorks ePublisher AutoMap" && tar xpf -)

# 2. Stage the seeded jobs and absolutize their Folder destinations.
#    Without this, the relative Folder destination in the repo .waj is used
#    verbatim against the CLI's working directory, not the product folder.
python scripts/stage_seeded_jobs.py "Q:/WebWorks ePublisher AutoMap"

# 3. Static checks: relative paths resolve, format names match the Stationery.
python "<automap-skill>/scripts/validate-job.py" --check-documents --check-stationery \
  "Q:/WebWorks ePublisher AutoMap/Jobs/Quantum Sync Help/Quantum Sync Help.waj"

# 4. End-to-end, the way the Administrator runs a job (direct exe call, not
#    the skill wrapper -- see the note below).
"C:\Program Files\WebWorks\ePublisher\2026.1\ePublisher AutoMap\WebWorks.Automap.exe" \
  "--stagingdir=Q:\WebWorks ePublisher AutoMap\Staging" \
  "Q:\WebWorks ePublisher AutoMap\Jobs\Quantum Sync Help\Quantum Sync Help.waj"
# Staging: Q:\WebWorks ePublisher AutoMap\Staging\Quantum Sync Help\Output\Web Help\
# Deployed: Q:\WebWorks ePublisher AutoMap\Output\Quantum Sync Help\

# 5. Tear down. (Git Bash turns a bare /D into a path, hence the env var; in cmd or
#    PowerShell it is plain `subst Q: /D`.)
MSYS_NO_PATHCONV=1 subst Q: /D
```

The skill wrapper's defaults (`-n`, `--skip-reports`, `-AllTargets`) suppress the deploy and build PDF, so it is not used for seeded jobs; call the executable directly instead.

Last run: 2026-09-02 against AutoMap 2026.1.4755 via `Invoke-Automap.ps1` (skill 3.9.4) — validation 8/8 checks passed; Web Help and PDF both built exit-0 (Web Help 0 warnings, PDF only stock Apache FOP font and table-layout warnings); the staged project's `<Origin>` recorded the contract-relative Stationery path; neither output contained an "Express" identifier (that run used the wrapper's -AllTargets; seeded jobs now build Web Help only, see docs/agents/seeded-jobs.md).

To verify the re-skin, build a second job whose `<Project path>` names Quantum Sync Midnight Stationery, or repoint the first job and re-run it (the guide's mechanic: AutoMap re-synchronizes the staged project against the new origin). Compare the two Web Help outputs: apart from per-build identifiers (generation hash, group and page IDs), only root `css/*.css`, `toolbar-logo.svg`, `footer-logo.svg` and `favicon.png` should differ; the per-document style-mapping CSS under `<Group>\css\` and the PDF text must be identical.

Last re-skin run (#31): 2026-09-02 against AutoMap 2026.1.4755 — `Quantum Sync Help` (base) and `Quantum Sync Help Midnight` (variant) both built exit-0 for Web Help (0 warnings) and PDF (stock FOP warnings only); the reverb2 lint was clean; the outputs differed only as described above; repointing the already-staged base job at the variant and re-running produced the Midnight chrome.

## Relationship to the Express and Designer materials

- **Quantum Sync Stationery is a copy of ePublisher Express Trial Stationery** with the folder, `.wxsp`, and `.manifest` renamed (ADR-0002). The `.wxsp` content is byte-identical: same Web Help (WebWorks Reverb 2.0) and PDF (PDF - XSL-FO) targets, same style mappings, same Quantum Sync branding assets. Nothing inside a Stationery names it, so the rename is complete once the three file-system names change.
- Both Stationeries are regenerated from the Designer Trial project by Save as Stationery; release migration therefore saves the Stationery twice (see `docs/agents/release-migration.md`).
- **Quantum Sync Midnight Stationery is Quantum Sync Stationery plus its own chrome** (ADR-0003). The `.wxsp` is byte-identical — same targets and target IDs, rules, variables, conditions and format settings — so the style mappings cannot differ. What differs is three files under `Files/` (midnight toolbar and footer logos, favicon) and `Formats/WebWorks Reverb 2.0/Pages/sass/` (`_colors.scss` with the midnight `$theme_` tokens, `custom.scss` with the toolbar accent). Those compile into the shell-owned root `css/`, which is exactly the chrome the re-skin step changes; the PDF target is untouched, and `og.png` and `pdf-cover.png` follow the base (they were already midnight compositions). `scripts/sync_variant_stationery.py` mirrors the `.wxsp`, format snapshots and Settings from the base, seeds any chrome file the variant lacks, and regenerates the manifest; it never overwrites the variant's chrome.
- **Quantum Sync Source Docs mirrors the Express Trial Project's `Source Docs/`**: the book (`quantum-sync.md`, `topics\`, `images\`) is a verbatim copy. Until the Express and Designer evaluations converge on the neutral asset (the future work ADR-0002 anticipates), an edit to the book is made in both places by hand. The Release Notes document (`release-notes.md`, added by #30) exists only here: the book does not include it, and it is built as its own publication by the Quantum Sync Release Notes seeded job.
- The Express and Designer trial materials, their `.wez` packaging, and `/package-trials` are untouched by this contract.
