# /publish-jobs

Build the Designer, Express and AutoMap online trial guides with AutoMap and deploy each one to its named S3 destination.

## Usage

```
/publish-jobs [JOB] [--dryrun]
```

- `JOB` — `trial-designer`, `trial-express` or `trial-automap`. Omit to publish all three.
- `--dryrun` — appends the AutoMap `--dryrun` switch: the S3 deploy prints its would-be DELETE / PUT / INVALIDATE sets and makes no AWS call. Rehearse with it after any change to a job, a trial target in `design.wep`, or a destination.

| Job | `design.wep` target | Destination | Published at |
|---|---|---|---|
| `automap-jobs/trial-designer.waj` | `Designer Trial` | `DocsDesignerTrial` | https://static.webworks.com/docs/epublisher/2026.1/designer/trial/ |
| `automap-jobs/trial-express.waj` | `Express Trial` | `DocsExpressTrial` | https://static.webworks.com/docs/epublisher/2026.1/express/trial/ |
| `automap-jobs/trial-automap.waj` | `Automap Trial` | `DocsAutomapTrial` | https://static.webworks.com/docs/epublisher/2026.1/automap/trial/ |

## Prerequisites

- **The sibling epublisher-docs clone at `C:\Projects\epublisher-docs`** (the jobs' `<Project path>`). Its `webworks\design\design.wep` is used as a stationery (`useAsStationery="True"`): the `Designer Trial`, `Express Trial` and `Automap Trial` targets there supply every setting, condition and variable, including each guide's own AI Assistant ID (the `Automap Trial` target's is empty until an assistant for that guide exists in the WebWorks Platform, so its knowledge archive is produced but no assistant is wired yet). Its `webworks\deploy-targets.xml` defines all three destinations. AutoMap reads that working copy as it is on disk, uncommitted edits included, so check `git status` there before a live run.
- **A federation-capable 2026.1 AutoMap** (2026.1.4737.0+). Resolve the CLI from the registry: `HKLM\SOFTWARE\WebWorks\ePublisher AutoMap\<ver>\Path` + `\WebWorks.Automap.exe` (the `ExePath` value names the Administrator, not the CLI). Use `AUTOMAP_EXE_PATH` only when it is set explicitly.
- **AWS credentials** for a live run: AutoMap resolves them from the default profile/role chain; `deploy-targets.xml` holds none.

## Steps

1. **Resolve the jobs**: `automap-jobs/<JOB>.waj` when `JOB` is given (error if it does not exist), otherwise every `automap-jobs/*.waj`. Run them sequentially.

2. **Build + deploy** each job by invoking the AutoMap exe directly, from PowerShell:

   ```powershell
   & $exe --skip-reports "--stagingdir=C:\automap\staging" "--deploysettings=C:\Projects\epublisher-docs\webworks\deploy-targets.xml" [--dryrun] "<repo>\automap-jobs\<JOB>.waj"
   ```

   - Do NOT go through the automap skill's wrapper: its default `-n` skips the named-destination deploy. Do NOT pass `-d`/`--deployfolder`: it bypasses the named destination.
   - `--stagingdir` is required. It makes step 3's harvest path true, and keeps staged output out of the OneDrive-synced default Staging folder.
   - Set the timeout to 600000ms per job.
   - Confirm the log shows `Destination '<name>' resolved from the --deploysettings file`. The job writes `<JOB>-log.txt` beside the job file (gitignored).

3. **Harvest the knowledge base** (live runs only). Each trial target generates a per-parcel knowledge archive for its guide's AI Assistant. Copy `C:\automap\staging\<JOB>\Output\<TARGET>\knowledge-parcel-*.zip` to `automap-jobs/knowledge/<JOB>/` (gitignored), after deleting the older archives there with the same `knowledge-parcel-<slug>-` prefix. If the staged output is missing, warn: the AutoMap "remove temporary files" preference deletes staging after the run.

4. **Verify** (live runs only): each published URL in the table above returns HTTP 200 and serves the rebuilt guide.

5. **Report** per job: build result and time, error count, the destination and where it resolved from, and the deploy summary (PUT / DELETE / INVALIDATE counts, or "dry run: printed only"). List each harvested archive under **"KB to upload"**, naming the guide's assistant. Uploading to the WebWorks Platform is manual today.

## Success Criteria

- Each job exits 0 with 0 errors, and its destination resolves from `deploy-targets.xml`.
- On a live run, all three URLs serve the rebuilt guides and the knowledge archives are harvested.
