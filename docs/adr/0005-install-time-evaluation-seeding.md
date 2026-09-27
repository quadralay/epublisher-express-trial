# AutoMap evaluation materials are seeded at install time, not on first Administrator launch

ADR-0001 planned first-launch extraction at `AutomapApplication.OnInitializePreferences`. Trunk shows that stub's `DefaultDirectoriesCreated` guard is machine-wide: AutoMap constructs with `base(true)`, so `Preferences.xml` is under ProgramData. The guard is not even persisted by the installer's `--register` run: the branch returns without disposing the application, and the only flush is in `PublisherApplication.Dispose`. It therefore cannot mark a per-user first launch.

A per-user first-launch design (the 2026-09-23 revision of the handoff spec) needed a new LocalAppData flag, a startup hook, a first-idle auto-open and a Help-menu item. It still left edge cases: whether a given user wants the materials, users who never launch interactively, and upgrades onto production machines. Express, meanwhile, seeds in its application constructor, which its installer's `--register` run executes first, so Express materials in practice land at install time for the installing account.

## Considered Options

- First-launch extraction per user (rejected: per-user state, startup timing
  with the licensing dialog, and ambiguous intent).
- Seeding from the shared `OnInitializePreferences` stub (rejected: it also
  runs for CLI and scheduled tasks, and its guard is machine-wide and
  unpersisted at install).
- Install-time seeding in the Administrator's `--register` branch (chosen).
- Holding the trial until AutoMap Workspaces (Trac #2919) ship (rejected as a
  hard dependency: the published trial guide already assumes seeded jobs;
  adopted as the preferred layout when #2919 lands in the same build).

## Consequences

Decision: the installer's registration step (`--register`, interactive
installs only; silent installs skip) extracts `Exp_AutoMap.wez` into the
installing user's Documents when the materials are absent and, in
default-root mode, the Jobs folder holds no jobs and has not been relocated;
it never overwrites. Reset Evaluation Materials in Preferences is required:
it serves other Windows users, installs elevated under another administrator
account, silent installs, and restore-after-Delete.

The installer's Finish page links to the versioned trial guide; there is no
Administrator startup auto-open and no Help-menu item. A Getting Started topic
in the AutoMap help points to the guide. The extraction root is one parameter:
`<Documents>\WebWorks ePublisher AutoMap` by default, or a dedicated Quantum
Sync Trial workspace folder if #2919 ships in the same build; the layout
inside the root is unchanged. Seeded jobs are never migrated between roots,
because scheduled tasks store the absolute job path and are never rewritten.

The extraction-layout contract's inner layout, the payload and the seeded
jobs are unchanged. The handoff spec
(`docs/plans/2026-09-23-feat-automap-trial-trunk-handoff-spec.md`) and Trac
#2975 carry the revised design. The materials land in the elevated account's
Documents (the installing user under a consent prompt, the credentialed
administrator under over-the-shoulder elevation), which Reset covers. Silent
installs break Express parity deliberately. If workspace mode ships, the
published guide's paths and screenshots are updated in this repo.

This supersedes the first-launch part of ADR-0001.