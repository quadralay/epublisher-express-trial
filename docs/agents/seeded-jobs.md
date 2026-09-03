# AutoMap seeded jobs and composition rehearsal

This document records the three AutoMap seeded jobs and the Quantum Sync Site Composition job rehearsal delivered for GitHub issue #32, part of spec #28. The jobs live in the repository mirror at `latest/local-trial-projects/WebWorks ePublisher AutoMap/Jobs/<name>/<name>.waj`; vocabulary follows `CONTEXT.md`, and ADR-0004 records the destination decision.

## The three jobs

| Job | Group | Document | Targets | Destination name | Destination folder |
|-----|-------|----------|---------|------------------|--------------------|
| Quantum Sync Help | Help | `..\..\Evaluation\Quantum Sync Source Docs\quantum-sync.md` | Web Help (build), PDF (skip) | Quantum Sync Help | `Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Help\` |
| Quantum Sync Release Notes | Release Notes | `..\..\Evaluation\Quantum Sync Source Docs\release-notes.md` | Web Help (build), PDF (skip) | Quantum Sync Release Notes | `Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Release Notes\` |
| Quantum Sync Site Shell | — | zero-document, `<Files />` | Web Help (build), PDF (skip) | Quantum Sync Site Shell | `Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Site Shell\` |

All three use the origin `..\..\Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp`, `<Options skipReports="True" verboseLogging="True" />`, and the current 2026.1 XML shape: `<Conditions>` and `<MergeSettings title="">` are present, and the target destination attribute is `destination`. The job identity rule is folder name = file name = the `name` attribute on `<Job>`.

The Web Help target keeps the Administrator default `cleanOutput="False"`. The earlier `cleanOutput="True"` experiment exposed the inferred-role problem rather than a `cleanOutput` problem: members deployed at `Everything` scope into the shared destination, and each cleaned the whole shared destination before its own deploy, wiping prior members. With explicit roles (the correction described below in "Composition: what the guide will tell the user"), a member cleans only its own slice, so `cleanOutput="True"` would be safe now; there is no reason to depart from the Administrator's default for the trial's fixed, unchanging content. The repo's own publishing jobs in `automap-jobs/` use `cleanOutput="True"` because they never take part in a composition.

This is a Web Help site, so Web Help is the only target built. PDF remains listed with `build="False"`: its Apache FOP warnings and build time add nothing to this composition, while Administrator target synchronization re-adds a missing Stationery target with build on; a listed target with build off is left alone.

Reports are skipped because the Administrator default would log `[WARN] Report 'Report-Styles' for group 'Help' contains 0 errors and 29 warnings.` The 29 entries are for Markdown++ marker styles `mdpp-version`, `date`, `Link Title`, and paragraph style `HTML` that the Stationery does not define, a pre-existing gap tracked as issue #42. Skipping reports keeps the first log at `0 warning(s), 0 error(s) reported.` and away from the Staging folder; the log states `Skipping report generation (requested via --skip-reports or the job's build options)`.

## Destination strategy

ADR-0004 decides that every seeded job deploys its Web Help output to a local Folder destination named after the job at `Documents\WebWorks ePublisher AutoMap\Output\<job name>\`. The in-guide Composition job deploys to `Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Site\` with destination name `Quantum Sync Site`. Thus every site sits under one Output folder beside Jobs, Staging, and Evaluation, and the user reaches output through Administrator Explore Output or Preview Output in Browser, never by browsing to Staging.

The repository `.waj` carries the relative destination `..\..\Output\<name>`, using the same relative form as the other seeded paths. First-launch extraction for #37 must rewrite each relative Folder-destination `Configuration Value` to an absolute path under the AutoMap product folder, resolving it against the folder containing the `.waj`. `scripts/stage_seeded_jobs.py` is the reference implementation: `python scripts/stage_seeded_jobs.py "<product folder>" [--source <mirror>] [--dry-run]` copies `Jobs\<name>\<name>.waj` into the product folder and rewrites `..\..\Output\<name>` to the corresponding `Documents\WebWorks ePublisher AutoMap\Output\<name>\`; Project and Document paths stay relative, already-absolute values are untouched, and staging onto its own source is refused. A build-time change to resolve relative Folder destinations against the job folder is a possible later enhancement, not a requirement.

The following facts are source-derived from the ePublisher trunk and are not yet observed in the GUI; screenshot staging in #35 will observe the GUI behavior later. `Publish/Core/Deployment/FolderDeployTarget.cs` uses `<Configuration Value>` verbatim, without full-path resolution or environment-variable expansion; it creates the folder if missing and cleans it only when `cleanOutput="True"`. `Automap/Core/JobManager.cs` and `Automap/Core/TaskSchedulerManager.cs` show that the Administrator runs every job, including Run, through Windows Task Scheduler with an action of the executable plus the quoted absolute `.waj` path, no working directory, so the process starts in `C:\Windows\System32`; the CLI never sets a working directory. Because `Documents` varies per user and may be OneDrive-redirected, no fixed absolute path works.

## What the Administrator does with output

Source-derived behavior, not yet observed in the GUI: `Automap/AutomapUI/UI/JobsForm.cs` and `Publish/Core/Deployment/DeployPreview.cs` indicate that Explore Output and Preview Output in Browser are one dropdown each, with one entry per target that has a deploy destination, captioned by target name. A target with `build="False"` and a destination is listed disabled; a target without a destination is not listed; a job with no destination shows one `no deploy targets found` entry. Neither command opens Staging.

Explore Output opens the destination folder in File Explorer. Preview Output in Browser opens the destination entry page as a local `file://` file: the name from the shell descriptor when present, otherwise `index.html`; before the first run it fails with a folder-not-found message. Both commands are enabled as soon as exactly one job is selected. View Log is enabled once `<name>-log.txt` exists beside the `.waj`.

For a Composition job, the same commands have one entry named by the composition `Destination`; Preview opens `index.html` in that folder. The Administrator scans `Jobs\<sub-folder>\*.waj|*.wacj` live, and a job log is `<name>-log.txt` beside the job file.

## Composition: what the guide will tell the user

The Administrator asks only for the name `Quantum Sync Site`, saves `Documents\WebWorks ePublisher AutoMap\Jobs\Quantum Sync Site\Quantum Sync Site.wacj`, and opens the composition editor. Add members in this order: Quantum Sync Site Shell, Quantum Sync Help, Quantum Sync Release Notes; set Role to Shell for Quantum Sync Site Shell and Parcel for the other two (do not leave Role on Infer); leave Build checked (the derivative composition default) and target `(automatic)`. The validator's `No member declares role="shell"` warning means a role was left inferred; do not leave it so, because inferred roles make every member deploy the full site, including chrome, into the shared destination at deploy scope `Everything`, so the composed chrome would be whichever member built last and the guide's later re-skin step would break.

Choose Merge: Automatic, which writes no `<MergeSettings>`. Choose an inline Folder destination, destination name `Quantum Sync Site`, and folder `Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Site`.

The Administrator writes this XML, rehearsed verbatim with the drive-letter path represented by the Documents path:

```xml
<?xml version="1.0" encoding="utf-8"?>
<CompositionJob name="Quantum Sync Site" version="1.0">
  <Jobs>
    <Job path="..\Quantum Sync Site Shell\Quantum Sync Site Shell.waj" role="shell" build="true" />
    <Job path="..\Quantum Sync Help\Quantum Sync Help.waj" role="parcel" build="true" />
    <Job path="..\Quantum Sync Release Notes\Quantum Sync Release Notes.waj" role="parcel" build="true" />
  </Jobs>
  <Destination name="Quantum Sync Site">
    <DeploySettings>
      <DeploySetting Name="Quantum Sync Site" Action="file">
        <Configuration Value="C:\Users\<you>\Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Site" />
      </DeploySetting>
    </DeploySettings>
  </Destination>
</CompositionJob>
```

Members are referenced by path and parcels by group name, never by GroupID. The member order is the site order; the shell contributes chrome, not a parcel.

## Rehearsal results

Last run: 2026-09-02 with AutoMap 2026.1.4755, using `scripts/rehearse_seeded_jobs.ps1` on a subst Q: mock of the extracted tree. Static validation with `validate-job.py --check-documents --check-stationery` passed 8/8 for all three; the shell additionally warned `No <Group> elements found`, which is expected for a zero-document job. `--check-members` on the `.wacj` passed 9/9 with no shell-role warning. `list-job-targets.py` showed Web Help [BUILD], PDF [SKIP] for each job and `(auto-detect per member)` for the composition.

Individual builds ran as the Administrator runs them (`WebWorks.Automap.exe "<job>.waj"`, plus `--stagingdir` to keep staging on the mock): builds took 22-40 s each, with Site Shell fastest; Site Shell deployed 54 files, Help deployed 93 files, and Release Notes deployed 76 files. Every log ended `0 warning(s), 0 error(s) reported.` and no PDF was produced. The shell output root contained `connect\`, `css\`, `scripts\`, `index.html`, `not-found.html`, `search.html`, `splash.html`, `robots.txt`, `sitemap.xml`, `sitemap-pages.xml`, `url_maps.xml`, and `wwcomposition-shell.xml`; it was chrome only.

The composition exited 0 in 110-150 s. Each member target auto-detected as Web Help (WebWorks Reverb 2.0), and the log stated that each member “deploys to this composition's destination 'Quantum Sync Site'”, each at its role's deploy scope. It reported `Found deployed output for 2 group(s); 2 group(s) composed, 0 warning(s), 0 error(s) reported.` The composed root contained the shell chrome above plus `Help.html`, `Help\`, `Help_ix.html`, `Help_lx.js`, `Help_sx.js`, `Release Notes.html`, `Release Notes\`, `Release Notes_ix.html`, `Release Notes_lx.js`, and `Release Notes_sx.js`. The `#parcels` manifest in `index.html` listed `data-group-title="Help"` then `data-group-title="Release Notes"`; the shell contributed chrome, not a parcel.

With roles declared, the composition log showed the Site Shell member deploying 54 files at deploy scope `shell`, and the parcels deploying 39 files for Help and 22 files for Release Notes at deploy scope `groups`, into `Output\Quantum Sync Site`. The log then reported `Found deployed output for 2 group(s)` and `2 group(s) composed, 0 warning(s), 0 error(s) reported.` The rehearsal script asserted chrome provenance: every file under the composed root's `css\` folder was byte-identical to the Site Shell's own standalone output, and `wwcomposition-shell.xml` was identical apart from its per-build `generationHash` attribute. With roles left inferred, the same members had deployed 54, 93, and 76 files at deploy scope `everything`—the last-writer chrome problem described earlier in this document.

The reverb2 skill's `lint-output.py` on the composed site reported `OK - no issues found` (exit 0). The reverb2 `browser-test.js --vanilla` check over `file://` passed for the composed site with exit 0, `success: true`, `reverbLoaded: true`, `parcelsLoadedAll: true`, the toolbar and TOC present with 54 TOC items, `errorCount: 0`, `warningCount: 0`, and a load time of about 0.4 s. The same check passed for the single Quantum Sync Help job's own output with `success: true`, `reverbLoaded: true`, `parcelsLoadedAll: true`, the toolbar and TOC present, `errorCount: 0`, `warningCount: 0`, and a load time of about 0.4 s, with 37 TOC items. The TOC evidence scan found both group names (Help and Release Notes) across the parcel pages, the `_ix.html`/`_lx.js`/`_sx.js` deploy units, each parcel's `wwcomposition-manifest.html`, and `index.html`, with `Help` appearing before `Release Notes` in `index.html`. The `file://` check was the reverb2 skill's automated load check, not a hand click-through in a real browser window; the hand click-through happens later, in the screenshot staging for issue #35.

The `browser-test.js` tool's `parcelsLoadedAll` signal is timing-sensitive over `file://`; its own header calls it a secondary signal, not as authoritative as `errorCount`/`reverbLoaded`. In the authoritative run, the composed site needed three attempts before `browser-test.js` reported all parcels loaded, while `errorCount` stayed 0 throughout and the TOC reached its full 54 items on the second attempt. Because of this, the rehearsal script retries the composed-site check up to three times, 3 seconds apart. The guide should set the expectation that the composed site's parcels appear a moment after the chrome loads, not simultaneously.

## Findings

Member builds spawned by a Composition job do not inherit `--stagingdir`; they stage under the product-default Staging folder, `Documents\WebWorks ePublisher AutoMap\Staging\<member name>\`. This is irrelevant to a trial user in the Administrator but matters for CLI rehearsals on a mock drive, so the rehearsal script removes only the folders it created there.

`--dryrun` against a Folder destination runs member builds but skips the compose; never use it to rehearse a compose. Issue #42 tracks the pre-existing Stationery report-style gap described above.

Inferred roles make a derivative composition deploy every member at "Everything" scope, so the composed chrome ends up being whichever member built last, and a re-skin of the shell alone would not take effect in the composed site. Declare roles explicitly (Shell / Parcel) for every member.

## Rehearsal tooling and hand-staging

`scripts/rehearse_seeded_jobs.ps1` is a PowerShell 5.1 rehearsal with parameters `-Drive` (default Q), `-ScratchRoot`, `-SkillRoot`, `-AutomapExe`, `-ChromePath`, `-EvidenceDir`, `-KeepDrive`, `-SkipBrowser`, `-NoRealStagingCleanup`, and `-RealStagingPath` (defaulting to `<Documents>\WebWorks ePublisher AutoMap\Staging`). `-SkillRoot` and `-AutomapExe` are auto-detected when omitted: `-SkillRoot` defaults to the highest installed automap skill version, and `-AutomapExe` defaults to the `AUTOMAP_EXE_PATH` environment variable if set, else the highest installed AutoMap release. Invoke it with `powershell -ExecutionPolicy Bypass -File scripts/rehearse_seeded_jobs.ps1`.

Its ten steps are: (1) preflight the free drive, executable, skills, jobs, and executable version; (2) subst the drive, copy Evaluation, and run `stage_seeded_jobs.py`; (3) statically validate via `validate-job.py` and related checks; (4) build the three jobs with real deploys; (5) write and compose the throwaway `.wacj`; (6) compare the real Staging listing before and after and remove only the member folders this run created there; (7) check composed output, parcel names from the manifest, TOC evidence, and `reverb2 lint-output.py`; (8) check the browser over `file://` with `reverb2 browser-test.js --vanilla`, or headless Chrome `--dump-dom`, and capture a screenshot of the composed site in either branch; (9) copy logs, `.wacj`, staged `.waj`, listings, and transcript to the evidence folder; (10) tear down with `subst /D`. The throwaway `.wacj` is never committed; the trial user creates it in-guide.

The rehearsal must be run outside any sandbox that blocks `subst`, since the script relies on `subst` to mount its scratch drive.

For hand-staging on a real machine for screenshots in #35, copy Evaluation according to `docs/agents/extraction-layout.md`, then run `python scripts/stage_seeded_jobs.py "<Documents>\WebWorks ePublisher AutoMap"`. This adds the three job folders to the live Jobs folder; remove them after capture.
