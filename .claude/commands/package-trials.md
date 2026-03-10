# /package-trials

Create `.wez` zip archives from local trial projects and copy them to the SVN evaluation directories.

## Usage

```
/package-trials
```

## Prerequisites

- Environment variable `SVN_LOCAL_PATH` must be set to the SVN trunk path
- 7-Zip must be installed at `C:/Program Files/7-Zip/7z.exe`

## Archive Mapping

Each archive is created by zipping the **contents** of a project folder (no parent folder wrapper):

| Source (under `latest/local-trial-projects/`) | Archive | SVN Destination (under `$SVN_LOCAL_PATH/`) |
|---|---|---|
| `ePublisher Designer Projects/ePublisher Designer Trial/` | `Exp_Design.wez` | `products/ePublisher/Evaluation/` |
| `ePublisher Express Projects/ePublisher Express Trial Project/` | `Exp_ePub.wez` | `products/Express/Evaluation/` |
| `ePublisher Stationery/<first folder>/` | `Exp_Stationery.wez` | `products/Express/Evaluation/` |

## Steps

1. **Validate environment:**
   - Confirm `$SVN_LOCAL_PATH` is set and the directory exists
   - Confirm 7-Zip is available
   - Set `LOCAL_PROJECTS` to `latest/local-trial-projects` (relative to repo root)

2. **Package Designer project** (`Exp_Design.wez`):
   - Source: `LOCAL_PROJECTS/ePublisher Designer Projects/ePublisher Designer Trial/`
   - Delete existing archive at destination if present
   - Create archive from the project folder contents:
     ```bash
     "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "$SVN_LOCAL_PATH/products/ePublisher/Evaluation/Exp_Design.wez" "$LOCAL_PROJECTS/ePublisher Designer Projects/ePublisher Designer Trial/*"
     ```

3. **Package Express project** (`Exp_ePub.wez`):
   - Source: `LOCAL_PROJECTS/ePublisher Express Projects/ePublisher Express Trial Project/`
   - Delete existing archive at destination if present
   - Create archive from the project folder contents:
     ```bash
     "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "$SVN_LOCAL_PATH/products/Express/Evaluation/Exp_ePub.wez" "$LOCAL_PROJECTS/ePublisher Express Projects/ePublisher Express Trial Project/*"
     ```

4. **Package Stationery** (`Exp_Stationery.wez`) — **only if content exists:**
   - Look for the first sub-folder inside `LOCAL_PROJECTS/ePublisher Stationery/`
   - If a folder containing a `.wxsp` file is found:
     - Delete existing archive at destination if present
     - Create archive from that folder's contents:
       ```bash
       "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "$SVN_LOCAL_PATH/products/Express/Evaluation/Exp_Stationery.wez" "$LOCAL_PROJECTS/ePublisher Stationery/<stationery-folder>/*"
       ```
   - If no stationery folder exists, skip with a note

5. **Report results** in a table showing each archive, its size, and status.

**IMPORTANT:**
- Do NOT use TodoWrite or task tracking tools
- Execute zip commands sequentially
- Delete the existing `.wez` at the destination BEFORE creating the new one (7-Zip appends to existing archives)
- Report results in a table and exit cleanly

## Expected Output

| Archive | Destination | Status |
|---------|-------------|--------|
| `Exp_Design.wez` | `products/ePublisher/Evaluation/` | Created |
| `Exp_ePub.wez` | `products/Express/Evaluation/` | Created |
| `Exp_Stationery.wez` | `products/Express/Evaluation/` | Created / Skipped (no stationery) |

## Success Criteria

- Designer and Express archives are always created
- Stationery archive is created only when stationery content exists
- Archives are written directly to the SVN evaluation directories
- Each archive contains project contents at the root level (matching existing `.wez` structure)
