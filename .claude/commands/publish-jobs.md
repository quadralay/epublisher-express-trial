# /publish-jobs

Publish all AutoMap job files in the `automap-jobs/` directory.

## Usage

```
/publish-jobs
```

## Prerequisites

- Environment variable `AUTOMAP_DEPLOY_PATH` must be set to the base deploy directory
- Environment variable `EPUBLISHER_STATIONERY_PATH` must be set to the Stationery file path
- Job files must exist in `automap-jobs/` directory

## Steps

1. **List all job files** by globbing `automap-jobs/*.waj`

2. **For each job file**, follow this process:

   a. **Parse the job file name** (e.g., `designer-trial-guide.waj`)

   b. **Derive the deploy folder name:**
      - Remove `.waj` extension
      - Example: `trial-designer.waj` → `DEPLOY_FOLDER=trial-designer`

   c. **Calculate the deploy path:**
      - `DEPLOY_PATH` = `$AUTOMAP_DEPLOY_PATH/$DEPLOY_FOLDER`

   d. **Execute the AutoMap build:**
      Invoke the `webworks-claude-skills:automap` skill with:
      - Job file: `automap-jobs/<JOB_FILE>`
      - Deploy path: `<DEPLOY_PATH>`
      - Flags: `-l` (clean deploy folder before deploying)
      - Set timeout to 600000ms (10 minutes) per job

   e. **Report progress** after each build completes

3. **Report final summary** showing all builds in a table.

**IMPORTANT:**
- Execute builds sequentially (not in parallel)
- Do NOT use TodoWrite or task tracking tools
- Report progress after each build
- Show final summary table when complete

## Expected Output

Progress updates after each build:
```
**<job-file>** - Success (XXXs)
```

Final summary table:

| Job File | Deploy Folder | Build Time | Status |
|----------|---------------|------------|--------|
| `trial-designer.waj` | `trial-designer` | XXXs | Success |
| `trial-express.waj` | `trial-express` | XXXs | Success |

## Success Criteria

- All job files in `automap-jobs/` are processed
- Each build exits with code 0
- Output deployed to `$AUTOMAP_DEPLOY_PATH/<deploy-folder>`
- Final summary shows all builds completed
