# AutoMap evaluation materials live in a shared Quantum Sync Trial workspace under Public Documents

## Context

AutoMap Workspaces shipped as SVN r36120 (Trac #2919). The workspace registry (`Workspaces.prefs`) and active-workspace selection (`ActiveWorkspace` in `AdminUI.prefs`) are machine-wide under `%ProgramData%\WebWorks\ePublisher AutoMap\2026.1\`.

ADR-0005 chose install-time seeding and a dedicated workspace if Workspaces shipped. The workspace's inner layout (Jobs, Staging, Output, Evaluation), seeded jobs, and their relative paths remain unchanged; only the root location changes.

## Considered Options

- Seed into the Default workspace Jobs folder (rejected: it clutters an existing job list, the same reason ADR-0005 preferred a dedicated workspace).
- Put one workspace in the installing user's Documents (rejected: every user's machine-wide list points into one profile; another user sees an empty or inaccessible workspace, and OneDrive-redirected Documents brings back placeholder-file issues).
- Create per-user Documents workspaces with per-user names (rejected: the machine-wide registry shows every user's entry to every user, while same-named seeded jobs in different folders compete for one machine-wide scheduled-task name, `waj <job name>`).
- Put one shared workspace under Public Documents (chosen: it matches the registry's machine-wide scope, gives each seeded job one path and one task, and default Public Documents ACLs grant inheritable Modify to INTERACTIVE, SERVICE, and BATCH).

Public Documents is not redirected to OneDrive. The deepest payload file is 126 characters relative to the workspace and 199 characters under the full Quantum Sync Trial path, within `MAX_PATH`.

## Decision

The workspace lives at `<Public Documents>\WebWorks ePublisher AutoMap\Quantum Sync Trial\`, registered as `Quantum Sync Trial` with JobsDirectory `<ws>\Jobs` and StagingDirectory `<ws>\Staging`. There is no separate workspace manifest file.

During the installer's interactive registration step (`--register`), the installer extracts the archive into `<ws>` when `<ws>` is absent, verifies the sentinel files and absolutizes the Folder destinations. It then registers or updates the workspace through the `AutomapUIWorkspaces` API (`Validate`, `Store`) whether or not it extracted, so a workspace folder whose entry was lost is registered again. Activate it only on a genuinely fresh machine: no other named workspace is registered and the Default workspace's Jobs folder is empty.

"Reset Evaluation Materials" replaces the shared materials for every user, leaves other jobs already in that workspace untouched, and (re)activates it.

## Consequences

- This supersedes ADR-0005's default-root mode.
- This also supersedes ADR-0005's earlier suggestion of a per-user workspace location.
- ADR-0005's install-time timing, silent-install skip, required Reset action, and Finish-page link all still stand unchanged.
- ADR-0004 rejected `C:\Users\Public\Documents` because a hard-coded path was baked into job files. Here the product resolves CommonDocuments dynamically at extraction time and the Administrator surfaces the folder in its UI, so that earlier rejection does not apply to this design.
- Guide prose calls this location "Public Documents".
- A Reset performed by any one user affects every user of the machine.
- Users share the seeded job list and generated output, so changes are visible across accounts.
- The trial guide and its screenshots must change whenever a build ships this layout.