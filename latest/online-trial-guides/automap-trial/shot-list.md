# AutoMap trial guide shot-list

This file lists every `automap-*.png` the guide references, captured for issue #35 against a hand-staged seeded state. Images are captured on a 200% DPI display: dialogs and wizard pages at 1:1 (about 850-1500 px wide), the Administrator main window at half scale (about 1290 px wide), and browser views with headless Chrome at 1800x1150; PNG; product-prefixed names.

| Image | Step | Window or page | Must show |
|---|---|---|---|
| `automap-job-list.png` | Step 1 | WebWorks ePublisher AutoMap Administrator | Job list before any run: three seeded jobs, Last Run Never |
| `automap-preview-output.png` | Step 1 | WebWorks ePublisher AutoMap Administrator | Job > Preview Output in Browser submenu open showing Web Help for the selected Quantum Sync Help row after its first run |
| `automap-new-job.png` | Step 2 | New ePublisher AutoMap Job | New ePublisher AutoMap Job dialog with Create a new publishing job selected and Quantum Sync Stationery.wxsp path |
| `automap-target-configuration.png` | Step 2 | Target Configuration | Target Configuration, Web Help selected, Variables tab with ProductName changed to Quantum Sync Pro (destination already set on the Info tab) |
| `automap-composition-editor.png` | Step 3 | Composition Job - Quantum Sync Site | Composition Job - Quantum Sync Site: three members with roles Shell/Parcel/Parcel, Build checked, Automatic merge, Defined in this job with destination Quantum Sync Site |
| `automap-composed-site.png` | Step 3 | Quantum Sync Site | Composed site with Help and Release Notes in the contents; parcels appear a moment after the chrome |
| `automap-schedule-trigger.png` | Step 4 | New Task Properties (Local Machine) | Triggers tab with a Daily trigger; never the General tab, which shows the account name |
| `automap-last-result.png` | Step 4 | WebWorks ePublisher AutoMap Administrator | Job list row showing Last Result OK, Scheduled Yes, Next Run |
| `automap-edit-job-stationery.png` | Step 5 | Edit Job: Quantum Sync Site Shell | Edit Job: Quantum Sync Site Shell, Job Info, the stationery field showing the Quantum Sync Midnight Stationery path |
| `automap-midnight-site.png` | Done | Quantum Sync Site | Composed site with midnight chrome, Help and Release Notes in the contents |

Staging the state: copy `Evaluation\` into the AutoMap product folder as described in [docs/agents/extraction-layout.md](../../../docs/agents/extraction-layout.md), then stage the seeded jobs with `python scripts/stage_seeded_jobs.py` as described in [docs/agents/seeded-jobs.md](../../../docs/agents/seeded-jobs.md). The job created in Step 2, **My Quantum Sync Help**, and the Quantum Sync Site composition are created live during capture; they are not part of the pre-seeded state. Step 2's Folder destination, **My Quantum Sync Help**, is stored in AutoMap's machine-local deploy destinations (Edit > Deploy Destinations...); remove it there after capture. Capturing with the Job and Staging folder preferences pointed at a neutral product folder (for example under Public Documents) keeps personal paths out of the dialogs; restore both preferences afterwards.
