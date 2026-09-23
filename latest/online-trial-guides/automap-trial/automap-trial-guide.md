---
mdpp-version: 1.0
date: 2026-09-12
description: ePublisher AutoMap trial — run, create, compose, schedule, and re-skin publishing jobs
keywords: automap, trial, getting started, publishing job, composition, scheduling, stationery
---

<!-- #quick-start -->
# Quick Start

AutoMap publishes and assembles documentation sites from jobs you can run, schedule and compose, without a designer at the keyboard (Markdown++ sources here; DITA, FrameMaker and Word work the same way).

> **Where things live:** Everything the trial uses is in your Documents folder under `WebWorks ePublisher AutoMap`: `Jobs`, `Evaluation`, and, after your first run, `Output`. Windows may show Documents under a localized name or inside OneDrive; the Administrator's own commands take you to the right place.

<!-- #run-a-publication -->
## Step 1: Run a Publication

Publishing should be a button, not a project. Run a seeded job to see the complete path from job list to published site.

1. Open **WebWorks ePublisher AutoMap Administrator** (**Start** > **WebWorks** > **ePublisher AutoMap**). The job list already holds the three seeded jobs, **Quantum Sync Help**, **Quantum Sync Release Notes**, and **Quantum Sync Site Shell**; none has run yet (**Last Run** reads **Never**).
2. Select **Quantum Sync Help** and choose **Job** > **Run**. When Windows opens the scheduled-task properties (AutoMap runs each job as a scheduled task), click **OK** to accept the defaults. A console window shows the build; when **Status** returns to **Ready**, **Last Result** reads **OK** (about half a minute).
3. Choose **Job** > **View log**. The log ends `0 warning(s), 0 error(s) reported.`.
4. Choose **Job** > **Preview Output in Browser** > **Web Help** to open the Quantum Sync help site. Then choose **Job** > **Explore Output for Target** > **Web Help** to open `Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Help`.

<!-- style:Screenshot -->
![AutoMap Administrator job list showing the three seeded jobs before any run](images/automap-job-list.png)

<!-- style:Screenshot -->
![AutoMap Administrator preview menu showing Web Help for Quantum Sync Help](images/automap-preview-output.png)

> **Tip:** **Quantum Sync Release Notes** is the job that changes often; Step 4 makes it run itself.

<!-- #create-a-publishing-job -->
## Step 2: Create a Publishing Job

Hand-building the same publication every release is where the hours go. A publishing job captures it once: a Stationery (the design) plus the documents it publishes.

1. Choose **File** > **New Job**. In **New ePublisher AutoMap Job**, choose **Create a new publishing job**; under **Choose ePublisher stationery or project:** browse to `Documents\WebWorks ePublisher AutoMap\Evaluation\Quantum Sync Stationery\Quantum Sync Stationery.wxsp`; click **OK**.
2. On **Job Info**, set **Job name:** to **My Quantum Sync Help**. Click **Next**.
3. On **Documents**, click **New Group** and name it **Help**; click **Add Document** and add `Documents\WebWorks ePublisher AutoMap\Evaluation\Quantum Sync Source Docs\quantum-sync.md`. Click **Next**.
4. On **Target Selection**, leave **Build** checked for **Web Help** and clear it for **PDF**. The Stationery carries both; one is enough for now. Click **Next**.
5. On **Target Configuration**, select **Web Help** in the target list, then the **Variables** tab; change `ProductName` from **Quantum Sync** to **Quantum Sync Pro**. The override belongs to this job and this target; the Stationery is untouched.
6. Select the **Info** tab; under **Deployment**, click **Deploy Destinations...**, then **Add** > **Folder**. Set **Name:** to **My Quantum Sync Help** and **Directory:** to `Documents\WebWorks ePublisher AutoMap\Output\My Quantum Sync Help`; click **OK**.
7. Pick **My Quantum Sync Help** under **Deploy to:** and click **Finish**. When the scheduled-task properties open, click **OK**.
8. Choose **Job** > **Run**, then **Job** > **Preview Output in Browser** > **Web Help**. The site now says Quantum Sync Pro.

<!-- style:Screenshot -->
![New ePublisher AutoMap Job dialog for creating a publishing job](images/automap-new-job.png)

<!-- style:Screenshot -->
![Target Configuration Web Help Variables with ProductName changed to Quantum Sync Pro](images/automap-target-configuration.png)

**Conditions** and **Target Settings** on the same page override the Stationery per target the same way.

<!-- #compose-a-site -->
## Step 3: Compose a Site

One site can combine publications that build on their own cadence: the shell brings the chrome, and the parcels bring content.

1. Choose **File** > **New Job**, choose **Compose published parcels into a website (Composition Job)**, and click **OK**. In the prompt, name it **Quantum Sync Site** and click **OK**. The **Composition Job - Quantum Sync Site** editor opens.
2. Under **Member Jobs**, click **Add...** and pick **Quantum Sync Site Shell**, then **Quantum Sync Help**, then **Quantum Sync Release Notes**.
3. Set **Role** to **Shell** for Quantum Sync Site Shell and **Parcel** for the other two (not **Infer**). Leave **Build** checked and **Output target** on **(automatic)**.
4. Set **Merge Settings** to **Automatic (compose every parcel found at the destination)**.
5. Set **Deployment** to **Defined in this job**, **Destination name:** **Quantum Sync Site**, **Deployment type:** **Folder**, and **Folder:** `Documents\WebWorks ePublisher AutoMap\Output\Quantum Sync Site`. Click **OK**.
6. Select **Quantum Sync Site** and choose **Job** > **Run**. Accept the scheduled-task properties with **OK** the first time. The three members build in turn, in about two and a half minutes.
7. Choose **Job** > **Preview Output in Browser** > **Quantum Sync Site**. One site shows **Help** and **Release Notes** side by side in the contents (the parcels can take a moment to appear after the chrome loads).

<!-- style:Screenshot -->
![Composition Job - Quantum Sync Site editor with shell and parcel roles](images/automap-composition-editor.png)

<!-- style:Screenshot -->
![Quantum Sync Site composed output with Help and Release Notes](images/automap-composed-site.png)

<!-- #make-it-run-itself -->
## Step 4: Make It Run Itself

Release notes change every sprint; nobody should have to remember to republish them.

1. Select **Quantum Sync Release Notes** and choose **Job** > **Schedule Job**. The Windows scheduled-task properties open for this job.
2. On the **Triggers** tab, click **New...**. In **New Trigger**, keep **Begin the task** on **On a schedule**, select **Daily**, set a start time, and click **OK**; then click **OK** to close the task properties.
3. Back in the job list, **Scheduled** reads **Yes** and **Next Run** shows the next time. To see it run now, choose **Job** > **Run**; when it finishes, **Last Run** shows the time and **Last Result** reads **OK**.

<!-- style:Screenshot -->
![Task properties for waj Quantum Sync Release Notes with a Daily trigger](images/automap-schedule-trigger.png)

<!-- style:Screenshot -->
![AutoMap Administrator job list showing Last Result OK, Scheduled Yes, and Next Run](images/automap-last-result.png)

> **No scheduled tasks allowed?** If your organization blocks them on this machine, skip the trigger and use **Job** > **Run** whenever the release notes change; the result is the same publication, run by hand.

<!-- #re-skin-the-site -->
## Step 5: Re-skin the Site

The design lives in the Stationery, not in the jobs: point the three seeded jobs at **Quantum Sync Midnight Stationery** (the same design with midnight chrome), run the composition again, and every publication follows.

1. For each seeded job — **Quantum Sync Site Shell**, **Quantum Sync Help**, and **Quantum Sync Release Notes** — select it and choose **Job** > **Edit...**. On **Job Info**, under **Choose ePublisher stationery or project:** browse to `Documents\WebWorks ePublisher AutoMap\Evaluation\Quantum Sync Midnight Stationery\Quantum Sync Midnight Stationery.wxsp`; click **OK**.
2. Select **Quantum Sync Site** and choose **Job** > **Run**.
3. Choose **Job** > **Preview Output in Browser** > **Quantum Sync Site**. The whole site now wears the midnight chrome (dark toolbar, sidebar and page frame, cyan accent); the content is unchanged.

<!-- style:Screenshot -->
![Edit Job: Quantum Sync Site Shell showing the Midnight Stationery path](images/automap-edit-job-stationery.png)

<!-- #done -->
## Done

You ran, created, composed, scheduled, and re-skinned a documentation site without opening a design tool.

<!-- style:Screenshot -->
![Quantum Sync Site with midnight chrome, Help, and Release Notes](images/automap-midnight-site.png)

**Next:** [Download ePublisher Designer](https://webworks.com/products/epublisher/download) to create your own Stationery: your brand, your layouts, your output formats — or keep reading to understand what you just built.

[Full documentation](https://static.webworks.com/docs/epublisher/latest/help/) | [Contact sales](mailto:sales@webworks.com)

---

<!-- #explore-more -->
## Explore More

You have seen the whole loop; here is how the pieces fit and what else AutoMap does.
