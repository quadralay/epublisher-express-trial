# ePublisher Trial Experiences

Documentation and evaluation materials for ePublisher trial users: online trial guides plus the sample projects, Stationery, and jobs that product installers seed onto an evaluator's machine.

## Language

### The experiences

**Trial**:
The user-facing evaluation experience for one product — its online guide plus the materials it walks through. User-facing surfaces say "trial."
_Avoid_: demo, tour

**Evaluation materials**:
The assets a product installer carries and extracts onto an evaluator's machine on first launch (projects, Stationery, source docs, jobs). Matches the product code's `Evaluation` folder naming.
_Avoid_: sample files, trial collateral

**Seeded job**:
A `.waj` included in evaluation materials, present in AutoMap Administrator's job list before the user has created anything.

**Trunk handoff spec**:
The Trac-ready document this repo delivers for the product-side work of the AutoMap trial (installer evaluation payload, first-launch extraction, trial-URL auto-open). The dev team implements it in `trunk`; this repo does not.

### AutoMap

**Administrator**:
AutoMap Administrator, the desktop application: the job list, the job and composition editors, Run, View Log, Explore Output and Preview Output in Browser. UI instructions say "the Administrator".

**Job**:
One `.waj` file: the tasks AutoMap performs from a single origin (Stationery or project) — run on demand, from the CLI, or on a schedule.

**Publication manifest**:
The teaching frame for a job: the recipe for one publication, or one part of a larger one. Narrative use only — UI instructions always say "job."

**Publishing job**:
A Stationery-based job (New Job → "Create a new publishing job"): Stationery origin plus the job's own document list, staged fresh each run.

**Composition job**:
A `.wacj` that references jobs as members and splices their deployed output into one site. The 2026.1 headline capability.
_Avoid_: Reverb 2 Compositions (marketing register), composite job

**Parcel**:
A composition member contributing content — one publication slice of the composed site.

**Shell**:
The single composition member providing site chrome (normally a zero-document build). Exactly one per composition.

**Chrome**:
The shell-owned visual layer of a Reverb site — entry page, theme CSS, scripts, search page. What the variant Stationery varies; parcel content styling is not chrome.

**Variant Stationery**:
The second evaluation Stationery, **Quantum Sync Midnight Stationery**: Quantum Sync Stationery with midnight chrome (dark toolbar, sidebar and page frame, cyan accent, light content card) and identical style mappings. The asset behind the guide's re-skin step; derived from the base by script rather than authored in Designer (ADR-0003).
_Avoid_: dark theme, dark mode (it is a Stationery a job points at, not a toggle)

**Derivative composition**:
A composition whose members have Build checked: the composition builds each member itself, overriding the member's deploy scope and destination by role. The Administrator's default; what the trial demonstrates.

**Federated composition**:
Members publish on their own cadence (`build="false"`); the composition only splices what is already deployed. Explore More depth, not a trial step.

**AutoMap product folder**:
`Documents\WebWorks ePublisher AutoMap` — the fixed, non-localized folder AutoMap owns under the user's Documents. Holds the product-default `Jobs` and `Staging` folders and, per the extraction-layout contract, the `Evaluation` and `Output` folders.

**Evaluation folder**:
`Evaluation` under the AutoMap product folder — where the AutoMap installer's evaluation materials other than seeded jobs are extracted (Quantum Sync Stationery, the variant Stationery, the Quantum Sync source docs). Seeded jobs reach it as `..\..\Evaluation\`.

**Output folder**:
`Output` under the AutoMap product folder — where every seeded job and the in-guide Composition job deploy, `Output\<job name>\`; Explore Output opens the selected destination folder; created by the first run.

**Folder destination**:
An inline deploy setting with `Action="file"`: AutoMap copies a target output to the folder named verbatim; the trial's only destination kind.

**Explore Output / Preview Output in Browser**:
The Administrator's two output commands: they act on a target deploy destination, opening its folder or its entry page over `file://`; there is nothing to show for a job without a destination, and they never open Staging.

**Workspace**:
The Administrator's set of jobs. One moveable workspace per install today; the next release plans multiple workspaces, each a set of jobs to compose and publish. Roadmap context only — the 2026.1 trial guide does not use this term.

### Content

**High-velocity content**:
Content that changes with every build — the trial's Release Notes parcel. The reason a job gets scheduled.

**Low-velocity content**:
Content that rarely changes — the trial's Quantum Sync book parcel. Composition splices it without rebuilding it.
