# Seeded jobs deploy Web Help to job-named Folder destinations under Output

The AutoMap trial is a Web Help composition: three seeded jobs and the in-guide Composition job need discoverable local output, while PDF adds warnings and time. A destination under the AutoMap product folder keeps every site beside Jobs, Staging, and Evaluation and lets the Administrator expose it through its output commands.

## Considered Options

- Omit destinations from seeded jobs (rejected: Explore Output would show `no deploy targets found`, and Step 1 would require deployment setup).
- Use a fixed absolute folder such as `C:\Users\Public\Documents` (rejected: machine assumption, not discoverable).
- Use an environment-variable placeholder (rejected: AutoMap expands none, and a Documents placeholder is wrong under OneDrive redirection).

## Consequences

Decision: every seeded job uses a local Folder destination named for the job at `Documents\WebWorks ePublisher AutoMap\Output\<job name>\`; the repo `.waj` carries the relative form `..\..\Output\<name>`, and extraction resolves it to the product folder. First-launch extraction must absolutize each relative Folder-destination configuration against the folder containing the `.waj`; `scripts/stage_seeded_jobs.py` is the reference implementation. The composition uses the same Output convention with destination name `Quantum Sync Site`. A later build-time change may resolve relative Folder destinations against the job folder, but it is not required. Because staged Folder destinations are absolute, unlike the relative Project and Document paths they do not automatically follow the AutoMap product folder if a user moves it after extraction; the possible future build-time resolution enhancement would remove that asymmetry by resolving the destination at build time instead of at extraction time.
