# /zip-jobs

Create zip archives for all deployed AutoMap job outputs.

## Usage

```
/zip-jobs
```

## Prerequisites

- Environment variable `AUTOMAP_DEPLOY_PATH` must be set to the base deploy directory
- Deploy folders must exist (run `/publish-jobs` first)

## Steps

1. **Get the deploy path** from `$AUTOMAP_DEPLOY_PATH`

2. **Identify deploy folders** by listing directories in the deploy path

3. **For each deploy folder**, create a zip archive:
   - Change to the deploy folder
   - Create zip file named `<folder-name>.zip` in the parent directory
   - Replace existing zip if it exists

   Use this bash pattern for each folder:
   ```bash
   "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "<DEPLOY_PATH>/<folder>.zip" "<DEPLOY_PATH>/<folder>/*"
   ```

   Note: Uses 7-Zip with `-mx=9` for maximum compression. The `-tzip` flag ensures standard zip format.

4. **Report results** showing which archives were created.

**IMPORTANT:**
- Do NOT use TodoWrite or task tracking tools
- Execute zip commands sequentially
- Report results in a table and exit cleanly

## Expected Output

| Deploy Folder | Zip Archive |
|---------------|-------------|
| `trial-designer` | `trial-designer.zip` |
| `trial-express` | `trial-express.zip` |

## Success Criteria

- All deploy folders are zipped
- Zip files created in `$AUTOMAP_DEPLOY_PATH/`
- Existing zip files are replaced
