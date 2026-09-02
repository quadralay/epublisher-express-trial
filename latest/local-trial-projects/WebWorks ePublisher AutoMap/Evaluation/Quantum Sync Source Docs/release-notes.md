---
mdpp-version: 1.0
date: 2026-08-25
description: What changed in each Quantum Sync 3.x release, including new features, fixes, and known issues
keywords: release notes, what's new, changes, fixes, known issues, 3.2, 3.1, 3.0
---

<!-- marker:IndexMarker="release notes" ; #release-notes -->
Quantum Sync Release Notes
==========================

[release-notes]: #release-notes "Release Notes"

These notes list what changed in each $ProductName; 3.x release, newest first. Every release includes new features, fixes, and known issues, and each known issue names the release that resolved it. Releases reach your devices through the **Update channel** setting: the Beta channel receives a release on the date shown, and the Stable channel receives it within seven days.

| Version | Released | Highlights |
|---------|----------|------------|
| [3.2][release-3-2] | August 25, 2026 | Scheduled bandwidth limits, change highlighting in version comparison, verified shared links |
| [3.1][release-3-1] | June 16, 2026 | Per-folder retention, offline status badges, Sync Now shortcut |
| [3.0][release-3-0] | March 10, 2026 | Offline Access, metered connection detection, idle-aware uploads, real-time change notifications |

> **Note:** Version numbers refer to the desktop application for Windows, macOS, and Linux. The iOS and Android apps follow the same numbering and usually ship a few days after the desktop release.

<!-- marker:IndexMarker="release notes:3.2" ; #release-3-2 -->
## Quantum Sync 3.2

[release-3-2]: #release-3-2 "Quantum Sync 3.2"

**Released:** August 25, 2026

### New features

- **Scheduled bandwidth limits** - The **Bandwidth limit (upload)** and **Bandwidth limit (download)** settings now accept a second value that applies outside working hours, so large uploads can run at full speed overnight without slowing the workday.
- **Change highlighting in version comparison** - Comparing versions side-by-side now highlights added and removed lines in text documents, including Markdown, CSV, and source code files.
- **Verified shared links** - A shared link can require the recipient to confirm an email address before opening, in addition to a password and an expiration date.

### Fixes

- **Pause sync on battery** no longer pauses synchronization on laptops that report battery power while connected to a docking station.
- Renaming a file on Linux no longer re-uploads the entire file. Delta sync now transmits the rename as a metadata change.
- The **Selective Sync** tab now lists cloud folders created after the application started, without a restart.

### Known issues

- On macOS, the **Sync Now** shortcut (Cmd+Shift+S) does not respond while the Settings window is open. Use the menu bar icon instead.
- Diagnostic reports omit proxy settings when **Proxy type** is set to the system proxy. Include your proxy details when contacting $SupportEmail;.

<!-- condition:advanced -->
### For administrators

- **Audit logging** now records changes to shared-link expiration dates and every remote wipe request, including the administrator who issued it.
- **Enforce encryption** now takes effect on each device at its next sign-in. Previously, devices that were already signed in had to reinstall the application.
<!-- /condition -->

<!-- marker:IndexMarker="release notes:3.1" ; #release-3-1 -->
## Quantum Sync 3.1

[release-3-1]: #release-3-1 "Quantum Sync 3.1"

**Released:** June 16, 2026

### New features

- **Per-folder retention** - Enterprise accounts can extend version history beyond 180 days for individual folders, up to 365 days. Extended retention previously applied to the whole account.
- **Offline status badges** - Files and folders marked for offline availability show a badge in File Explorer and Finder: available offline, waiting for connection, or conflict detected.
- **Sync Now shortcut** - Trigger a manual sync from the keyboard with Ctrl+Shift+S on Windows or Cmd+Shift+S on macOS, without opening the system tray menu.

### Fixes

- Files matching an **Ignore file patterns** entry, such as temporary files, were occasionally uploaded when created during an active sync.
- Connection errors through a SOCKS5 proxy that requires authentication were reported as a generic server error. The message now identifies the proxy.
- Conflict copies created while offline received a UTC timestamp instead of the device's local time.

### Known issues

- The offline status badge can lag behind the actual state by up to a minute after a large sync completes.
- Diagnostic reports omit proxy settings when **Proxy type** is set to the system proxy.

<!-- condition:advanced -->
### For administrators

- **Remote wipe** can now target a single device instead of every device on the account.
- Known issue: **Audit logging** does not record changes to shared-link expiration dates. Resolved in 3.2.
<!-- /condition -->

<!-- marker:IndexMarker="release notes:3.0" ; #release-3-0 -->
## Quantum Sync 3.0

[release-3-0]: #release-3-0 "Quantum Sync 3.0"

**Released:** March 10, 2026

$ProductName; 3.0 is a major release. Devices upgrading from 2.x re-scan their sync folder once after the update; see the known issues below.

### New features

- **Offline Access** - Mark files and folders for offline availability. Changes made without a connection are queued and synchronized when the connection resumes, with conflict detection for concurrent offline edits.
- **Metered connection detection** - Automatic sync pauses on metered connections such as cellular hotspots and resumes when the device returns to an unmetered network.
- **Idle-aware uploads** - In automatic mode, large uploads are throttled while you are actively working and accelerated when the device is idle.
- **Real-time change notifications** - Devices receive change notifications over a WebSocket connection on port 8443, so a change on one device appears on the others within seconds. Firewalls must allow outbound access on port 8443 in addition to port 443.

### Fixes

- Uploads interrupted by system sleep now resume from the last completed chunk instead of restarting.
- **Start on login** was ignored on Windows when the application was installed for all users.
- Compare versions side-by-side no longer fails for files larger than 100 MB.

### Known issues

- After upgrading from 2.x, the first sync re-scans the entire sync folder. Large folders can take several minutes to scan; no files are re-uploaded.
- On Linux desktops without a system tray, the $ProductName; icon does not appear, so **Sync Now** cannot be triggered from the tray. Use the web interface instead. Resolved in 3.1 by the Sync Now shortcut.
- Proxy authentication prompts appear twice when **Proxy type** is set to HTTP and the proxy requires credentials. Resolved in 3.1.
