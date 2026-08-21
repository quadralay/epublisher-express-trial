# Release migration workflow

When ePublisher ships a new runtime release (e.g., 2025.1 → 2026.1), the trial projects need to be migrated onto the new runtime and reconfigured for any new format-level settings. Runs once per release cycle, on top of the day-to-day maintenance flow in `docs/agents/trial-project-workflow.md`.

## Prerequisites

- ePublisher Designer installed at the new release version.
- Clone up to date on `master`.
- No pending uncommitted changes under `latest/local-trial-projects/` — commit or stash anything in flight first. Migration edits should not mix with unrelated work.

## Steps

### 1. Migrate the Designer project (`.wep`)

1. Open ePublisher Designer at the new release version.
2. File → Open Project → `latest\local-trial-projects\ePublisher Designer Projects\ePublisher Designer Trial\ePublisher Designer Trial.wep`.
3. Accept the migration prompt to bring the project onto the new runtime.
4. Walk through the project's overrides (paragraph styles, character styles, table styles, image handling, condition rules, variables, format settings). Confirm each survived migration. Where Designer has changed a default, decide per override whether to keep the existing value or accept the new default.
5. Under Format Settings for each target, review any Target Settings newly introduced in this release. Set each explicitly to the intended value so the trial anchors on that value rather than following whatever default a future release ships. See the release-specific notes below for known items.

### 2. Save the Stationery (`.wxsp`)

1. File → Save as Stationery.
2. Overwrite `latest\local-trial-projects\ePublisher Stationery\ePublisher Express Trial Stationery\ePublisher Express Trial Stationery.wxsp`.
3. Confirm the overwrite when prompted.

### 3. Sync the Express project (`.wrp`)

1. File → Open Project → `latest\local-trial-projects\ePublisher Express Projects\ePublisher Express Trial Project\ePublisher Express Trial Project.wrp`.
2. Designer detects the newer Stationery. Synchronize the project with it.
3. Save the project.

### 4. Package and commit

- Refresh the `.wez` archives per `docs/agents/trial-project-workflow.md` § "Refreshing `.wez` packages in the dev repo", then commit them to SVN.
- Open a PR against `master` bundling the `.wep`, `.wxsp`, `.wrp` changes plus any migration-triggered SCSS or asset updates.

## Release-specific notes

Track release-specific migration decisions here so they do not get lost.

### 2026.1

- **Disable "Use first document instead of splash page"** — this Target Setting was newly introduced in 2026.1. The trial projects should keep the existing splash-page behavior, so set this explicitly to disabled in each Target's Format Settings before saving the Stationery.
