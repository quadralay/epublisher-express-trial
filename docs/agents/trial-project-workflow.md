# Trial project workflow

Where the trial projects live, how to edit them, and how to refresh the `.wez` packages shipped in the ePublisher dev repo.

## Source of truth

This git clone is the source of truth for all trial-project content:

- Designer Trial: `latest/local-trial-projects/ePublisher Designer Projects/ePublisher Designer Trial/`
- Express Trial: `latest/local-trial-projects/ePublisher Express Projects/ePublisher Express Trial Project/`
- Express Stationery: `latest/local-trial-projects/ePublisher Stationery/ePublisher Express Trial Stationery/`
- AutoMap evaluation materials: `latest/local-trial-projects/WebWorks ePublisher AutoMap/` — Quantum Sync Stationery (ADR-0002) and the Quantum Sync source docs under `Evaluation/`, seeded jobs under `Jobs/`. The folder mirrors what the AutoMap installer extracts on a trial user's machine; see `docs/agents/extraction-layout.md`.

Historical copies at `C:\Users\mcdow\OneDrive\Documents\ePublisher *` predate this convention. Do not edit them — they will drift silently and cause sync headaches later. Archive or delete them at your leisure.

## Editing projects

**In ePublisher Designer** (for project settings, style rules, format configurations, source-doc registration):

1. Open Designer.
2. File → Open Project. Navigate to the clone path and open the `.wep` / `.wrp` file directly (e.g., `C:\Projects\epublisher-express-trial\latest\local-trial-projects\ePublisher Designer Projects\ePublisher Designer Trial\ePublisher Designer Trial.wep`).
3. Designer will remember the recent path on subsequent opens.
4. Make edits, save in Designer.

**In your editor of choice** (for Markdown++ source content under `Source Docs/`, SCSS under `Formats/`):

Edit files directly in the clone. If Designer is open on the project, close and reopen it to pick up file-content changes.

Commit source changes to git and open a PR per the usual repo conventions.

## AutoMap evaluation materials

The AutoMap trial ships its own copies of the Quantum Sync design and content so the AutoMap installer depends on neither Express nor Designer (ADR-0001). What the materials are, where they land on a trial user's machine, and how they relate to the Express and Designer materials is defined in `docs/agents/extraction-layout.md`. The maintenance rules:

- **Quantum Sync Stationery** (`WebWorks ePublisher AutoMap/Evaluation/Quantum Sync Stationery/`) is not edited directly. Regenerate it from the Designer Trial project with Save as Stationery, alongside the Express Stationery (`docs/agents/release-migration.md` § 2).
- **Quantum Sync Source Docs** (`WebWorks ePublisher AutoMap/Evaluation/Quantum Sync Source Docs/`) is a copy of the Express Trial Project's `Source Docs/`. An edit to the Quantum Sync book is made in both places until the evaluations converge (ADR-0002). The Release Notes document (`release-notes.md`) lives only here, has no Express counterpart, and is not included by the book; edit it in place. It uses only styles Quantum Sync Stationery maps (no italics or inline code, which the Helper Adapter emits as the unmapped `Italic` and `Code` styles).
- **Seeded jobs** (`WebWorks ePublisher AutoMap/Jobs/<name>/<name>.waj`) are authored by hand against the contract's relative-path rule and validated with the `automap` skill's scripts. Copy the folder's contents into `Documents\WebWorks ePublisher AutoMap\` to open them in AutoMap Administrator.

These materials are **not** part of the three `.wez` archives below. Packaging them into the AutoMap installer payload is defined with the trunk handoff spec.

## Refreshing `.wez` packages in the dev repo

The ePublisher dev repo at `%EPUBLISHER_DEV_PATH%` (typically `C:\Repo\ePublisher_debug\trunk`) ships three `.wez` archives that become the sample projects users see in the installed trial:

| Archive | Destination under `%SVN_LOCAL_PATH%\` |
|---------|----------------------------------------|
| `Exp_Design.wez` | `products\ePublisher\Evaluation\` |
| `Exp_ePub.wez` | `products\Express\Evaluation\` |
| `Exp_Stationery.wez` | `products\Express\Evaluation\` |

To refresh them:

1. **Purge generated dirs.** ePublisher writes `Logs/`, `Output/`, and `Reports/` into each project folder when it runs. These are gitignored and must not ship inside the `.wez`. Delete them from each of the three clone project folders before packaging:

   ```bash
   for p in \
     "latest/local-trial-projects/ePublisher Designer Projects/ePublisher Designer Trial" \
     "latest/local-trial-projects/ePublisher Express Projects/ePublisher Express Trial Project" \
     "latest/local-trial-projects/ePublisher Stationery/ePublisher Express Trial Stationery"; do
     rm -rf "$p/Logs" "$p/Output" "$p/Reports"
   done
   ```

2. **Run `/package-trials`.** This zips each project folder (contents at archive root) and writes the `.wez` directly to the three SVN evaluation directories. See `.claude/commands/package-trials.md` for the full mechanics.

3. **Sanity-check sizes.** Rough expected sizes:
   - `Exp_Design.wez` — ~1.6 MB (customizations + source docs only)
   - `Exp_ePub.wez` — ~3.0 MB (full baseline + source docs)
   - `Exp_Stationery.wez` — ~3.0 MB (full baseline)

   A meaningfully larger archive usually means generated dirs crept back in — re-check step 1.

4. **Commit to SVN.** Commit the updated `.wez` files in the dev repo (SmartSVN / TortoiseSVN / `svn commit`). Include a short message noting what changed in the trial content and which trial-repo PR it corresponds to.

## Baseline vs. source content

The `.gitignore` deliberately excludes baseline content that Designer regenerates:

- **Designer Trial** — everything under it is tracked (source + customizations)
- **Express Trial** — only `.wrp` and `Source Docs/` are tracked; `Files/`, `Formats/`, `stationery.manifest` are ignored (they come from the Stationery)
- **Express Stationery** — only `.wxsp` is tracked; `Files/`, `Formats/`, `Settings/`, `.manifest` are ignored (they come from adapter baselines)
- **Quantum Sync Stationery** (and any Stationery placed under `WebWorks ePublisher AutoMap/Evaluation/`) — same rule as the Express Stationery; the `.gitignore` globs cover every Stationery folder under `Evaluation/`
- **Quantum Sync Source Docs** and seeded jobs — tracked in full

The ignored files still have to exist on disk for Designer to open the projects, for AutoMap to build jobs against the Stationeries, and for `/package-trials` to produce complete `.wez` archives. If any of them go missing, reopen the project in Designer and let it re-apply the Stationery or reset the baseline; for a Stationery folder, re-run Save as Stationery from the Designer Trial project.

## When to package vs. when to commit

Every source-doc or project-file change goes to git (PR against `master`).

`.wez` packages get refreshed for the dev repo whenever you want that change to reach the installed trial — typically once per release cycle, or when a user-facing change to a trial project needs to be shipped in the next ePublisher build. The `.wez` files themselves live in SVN, not in this git repo.

## Related workflows

- **Release migration** — When ePublisher ships a new runtime release, follow `docs/agents/release-migration.md` to migrate `.wep`, save the updated Stationeries, and sync the Express `.wrp`. Refresh the `.wez` archives per this doc's packaging steps once the migration is complete.
- **Extraction-layout contract** — Where the AutoMap evaluation materials land on a trial user's machine and the relative-path rule seeded jobs follow: `docs/agents/extraction-layout.md`.
