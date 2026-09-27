# /package-trials

Create `.wez` zip archives from local trial projects and copy them to the SVN evaluation directories.

## Usage

```
/package-trials
```

## Prerequisites

- Environment variable `SVN_LOCAL_PATH` must be set to the SVN trunk path
- 7-Zip must be installed at `C:/Program Files/7-Zip/7z.exe`
- `python scripts/sync_variant_stationery.py --check` must exit 0 (Quantum Sync Midnight Stationery in sync with Quantum Sync Stationery) before the AutoMap archive is built.

## Archive Mapping

Each archive is created by zipping the **contents** of a project folder (no parent folder wrapper). The AutoMap archive zips the contents of the materials folder, so `Evaluation/` and `Jobs/` are its top-level entries:

| Source (under `latest/local-trial-projects/`) | Archive | SVN Destination (under `$SVN_LOCAL_PATH/`) |
|---|---|---|
| `ePublisher Designer Projects/ePublisher Designer Trial/` | `Exp_Design.wez` | `products/ePublisher/Evaluation/` |
| `ePublisher Express Projects/ePublisher Express Trial Project/` | `Exp_ePub.wez` | `products/Express/Evaluation/` |
| `ePublisher Stationery/<first folder>/` | `Exp_Stationery.wez` | `products/Express/Evaluation/` |
| `WebWorks ePublisher AutoMap/` | `Exp_AutoMap.wez` | `products/AutoMap/Evaluation/` |

## Steps

1. **Validate environment:**
   - Confirm `$SVN_LOCAL_PATH` is set and the directory exists
   - Confirm 7-Zip is available
   - Set `LOCAL_PROJECTS` to `latest/local-trial-projects` (relative to repo root)

2. **Package Designer project** (`Exp_Design.wez`):
   - Source: `LOCAL_PROJECTS/ePublisher Designer Projects/ePublisher Designer Trial/`
   - Delete existing archive at destination if present
   - `cd` into the source folder and create archive using `./*` so paths are rooted at the project level:
     ```bash
     rm -f "$SVN_LOCAL_PATH/products/ePublisher/Evaluation/Exp_Design.wez"
     cd "$LOCAL_PROJECTS/ePublisher Designer Projects/ePublisher Designer Trial"
     "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "$SVN_LOCAL_PATH/products/ePublisher/Evaluation/Exp_Design.wez" ./*
     ```

3. **Package Express project** (`Exp_ePub.wez`):
   - Source: `LOCAL_PROJECTS/ePublisher Express Projects/ePublisher Express Trial Project/`
   - Delete existing archive at destination if present
   - `cd` into the source folder and create archive using `./*`:
     ```bash
     rm -f "$SVN_LOCAL_PATH/products/Express/Evaluation/Exp_ePub.wez"
     cd "$LOCAL_PROJECTS/ePublisher Express Projects/ePublisher Express Trial Project"
     "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "$SVN_LOCAL_PATH/products/Express/Evaluation/Exp_ePub.wez" ./*
     ```

4. **Package Stationery** (`Exp_Stationery.wez`) — **only if content exists:**
   - Look for the first sub-folder inside `LOCAL_PROJECTS/ePublisher Stationery/`
   - If a folder containing a `.wxsp` file is found:
     - Delete existing archive at destination if present
     - `cd` into the stationery folder and create archive using `./*`:
       ```bash
       rm -f "$SVN_LOCAL_PATH/products/Express/Evaluation/Exp_Stationery.wez"
       cd "$LOCAL_PROJECTS/ePublisher Stationery/<stationery-folder>"
       "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "$SVN_LOCAL_PATH/products/Express/Evaluation/Exp_Stationery.wez" ./*
       ```
   - If no stationery folder exists, skip with a note

5. **Package AutoMap evaluation materials** (`Exp_AutoMap.wez`):
   - Source: `LOCAL_PROJECTS/WebWorks ePublisher AutoMap/`
   - Return to the repo root (earlier steps `cd` into project folders), run the variant check and abort this step if it fails
   - Create the destination directory if absent, delete the existing archive, then archive the folder contents so `Evaluation/` and `Jobs/` sit at the archive root:
     ```bash
     cd "$(git rev-parse --show-toplevel)"
     python scripts/sync_variant_stationery.py --check
     mkdir -p "$SVN_LOCAL_PATH/products/AutoMap/Evaluation"
     rm -f "$SVN_LOCAL_PATH/products/AutoMap/Evaluation/Exp_AutoMap.wez"
     cd "$LOCAL_PROJECTS/WebWorks ePublisher AutoMap"
     "/c/Program Files/7-Zip/7z.exe" a -tzip -mx=9 "$SVN_LOCAL_PATH/products/AutoMap/Evaluation/Exp_AutoMap.wez" ./*
     "/c/Program Files/7-Zip/7z.exe" l "$SVN_LOCAL_PATH/products/AutoMap/Evaluation/Exp_AutoMap.wez" | grep -E "Quantum Sync Help.waj|Quantum Sync Stationery.wxsp"
     ```
   - The archive is built from the working tree: git tracks only 20 of its 1,083 files; regenerated Stationery parts (`.manifest`, `Files/`, `Settings/`, `Formats/`) are gitignored, so the folder must be complete on disk, as with the Express Trial Stationery.
   - Confirm the listing contains `Jobs/Quantum Sync Help/Quantum Sync Help.waj` and `Evaluation/Quantum Sync Stationery/Quantum Sync Stationery.wxsp`.

6. **Report results** in a table showing each archive, its size, and status.

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
| `Exp_AutoMap.wez` | `products/AutoMap/Evaluation/` | Created |

## Success Criteria

- Designer and Express archives are always created
- Stationery archive is created only when stationery content exists
- Archives are written directly to the SVN evaluation directories
- Each archive contains project contents at the root level (matching existing `.wez` structure)
- AutoMap archive is always created; its root holds `Evaluation/` and `Jobs/`, and the variant check passed first
