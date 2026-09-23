# AutoMap trial guide shot-list

This file lists every `automap-*.png` the guide references, to be captured by issue #35 against a hand-staged seeded state. Sizes follow the Designer guide's images (measured: dialogs about 1000×660, as in `designer-target-variables.png`; full windows and browser views 1700–1850 pixels wide, as in `designer-output-result.png`); PNG; product-prefixed names.

| Image | Step | Window or page | Must show |
|---|---|---|---|
| `automap-job-list.png` | Step 1 | WebWorks ePublisher AutoMap Administrator | Job list before any run: three seeded jobs, Last Run Never |
| `automap-preview-output.png` | Step 1 | WebWorks ePublisher AutoMap Administrator | Job > Preview Output in Browser submenu open showing Web Help, Quantum Sync Help row with Last Result OK |
| `automap-new-job.png` | Step 2 | New ePublisher AutoMap Job | New ePublisher AutoMap Job dialog with Create a new publishing job selected and Quantum Sync Stationery.wxsp path |
| `automap-target-configuration.png` | Step 2 | Target Configuration | Target Configuration, Web Help, Variables with the edited ProductName |
| `automap-composition-editor.png` | Step 3 | Composition Job - Quantum Sync Site | Composition Job - Quantum Sync Site: three members with roles Shell/Parcel/Parcel, Build checked, Automatic merge, Defined in this job with destination Quantum Sync Site |
| `automap-composed-site.png` | Step 3 | Quantum Sync Site | Composed site with Help and Release Notes in the contents; parcels appear a moment after the chrome |
| `automap-schedule-trigger.png` | Step 4 | Task properties for waj Quantum Sync Release Notes | Task properties for waj Quantum Sync Release Notes, Triggers tab, Daily trigger |
| `automap-last-result.png` | Step 4 | WebWorks ePublisher AutoMap Administrator | Job list row showing Last Result OK, Scheduled Yes, Next Run |
| `automap-edit-job-stationery.png` | Step 5 | Edit Job: Quantum Sync Site Shell | Edit Job: Quantum Sync Site Shell, Job Info, stationery path ending Quantum Sync Midnight Stationery.wxsp |
| `automap-midnight-site.png` | Done | Quantum Sync Site | Composed site with midnight chrome, Help and Release Notes in the contents |

Staging the state: copy `Evaluation\` into the AutoMap product folder as described in [docs/agents/extraction-layout.md](../../../docs/agents/extraction-layout.md), then stage the seeded jobs with `python scripts/stage_seeded_jobs.py` as described in [docs/agents/seeded-jobs.md](../../../docs/agents/seeded-jobs.md). The job created in Step 2, **My Quantum Sync Help**, and the Quantum Sync Site composition are created live during capture; they are not part of the pre-seeded state. Step 2's Folder destination, **My Quantum Sync Help**, is stored in AutoMap's machine-local deploy destinations (Edit > Deploy Destinations...); remove it there after capture.
