<!-- markers:{"Keywords": "sync modes, automatic, manual, selective, bandwidth, callouts, tips, warnings", "Description": "Synchronization modes and bandwidth management for Quantum Sync.", "IndexMarker": "synchronization:modes"}; #sync-modes -->
## Sync Modes

$ProductName; offers three synchronization modes to accommodate different workflows and network conditions. You can switch between modes at any time through the application settings or system tray menu.

<!-- marker:IndexMarker="synchronization:automatic,real-time synchronization" ; #automatic-sync -->
### Automatic Sync

In automatic mode, $ProductName; monitors your sync folder continuously and uploads changes immediately. Downloads from other devices appear as soon as they are available. This mode is ideal for desktop computers with reliable internet connections.

Automatic sync uses intelligent scheduling to avoid interfering with your work:

- **Active use** — Large uploads are throttled to preserve bandwidth for your applications
- **Idle periods** — Transfer speeds increase to synchronize queued changes quickly
- **Metered connections** — Sync pauses automatically when your operating system reports a metered network

> **Tip:** You can override the metered connection behavior in [Sync Settings](conditions-and-variables.md#sync-settings). Set **Pause sync on battery** to *Disabled* if you want sync to continue during battery-powered sessions.

---

<!-- marker:IndexMarker="synchronization:manual" ; #manual-sync -->
### Manual Sync

Manual mode gives you complete control over when synchronization occurs. Changes are queued locally and transmitted only when you explicitly trigger a sync. This mode is useful when traveling or on metered cellular connections.

You can trigger a manual sync in three ways:

1. **System tray** — Right-click the $ProductName; icon and select **Sync Now**
2. **Keyboard shortcut** — Press `Ctrl+Shift+S` (Windows/Linux) or `Cmd+Shift+S` (macOS)
3. **Command line** — Run `quantumsync sync --now`

> ***Warning:*** When you switch from automatic to manual mode, any queued changes remain in the upload queue. They will **not** be discarded — they simply wait until you trigger the next manual sync.

---

<!-- marker:IndexMarker="synchronization:selective,storage:conservation" ; #selective-sync -->
### Selective Sync

Selective sync allows you to choose which cloud folders appear on each device. Folders you exclude are hidden from your local sync folder but remain accessible through the web interface and on other devices.

Use selective sync to conserve disk space on laptops, separate work and personal files across devices, or optimize mobile devices for essential content.

<!-- style:BQ Learn -->
> ### Disk Space Recovery
>
> When you exclude folders from selective sync, $ProductName; recovers disk space automatically:
>
> 1. Local copies of excluded files are removed from your device
> 2. The sync database is updated to reflect the change
> 3. Recovered space is reported in the status panel
>
> Your files remain safely stored in your cloud account and are accessible at quantumsync.example/files or on any other device where those folders are included.

---

<!-- #choosing-mode -->
### Choosing the Right Mode

If you are unsure which mode to use, consider the following guidelines:

- Use **Automatic** if you have a reliable, unmetered internet connection and want files available everywhere without intervention
- Use **Manual** if you are on a mobile hotspot, traveling, or need to control exactly when data is uploaded
- Use **Selective** if your device has limited storage or you only need access to specific project folders

> **Note:** You can switch between modes at any time without losing data. When you change modes, $ProductName; preserves your upload and download queues and resumes processing them according to the new mode's rules.

---

<!-- marker:IndexMarker="bandwidth:management,network:optimization" ; #bandwidth-management -->
### Bandwidth Management

$ProductName; allows you to limit upload and download speeds to avoid saturating your network connection. This is especially useful in shared office environments or on connections with limited throughput.

<!-- style:BQ Tip -->
> #### Recommended Bandwidth Settings
>
> | Connection Type | Upload Limit | Download Limit |
> |:----------------|:------------:|:--------------:|
> | Office LAN      | Unlimited    | Unlimited      |
> | Home Wi-Fi      | 500 KB/s     | Unlimited      |
> | Mobile hotspot  | 100 KB/s     | 250 KB/s       |
> | Satellite       | 50 KB/s      | 100 KB/s       |
>
> Configure these values in [Sync Settings](conditions-and-variables.md#sync-settings). Set a limit to **0** for unlimited throughput.

To check your current bandwidth usage, use the command-line tool:

<!-- style:BQ Learn -->
> #### Monitoring Bandwidth
>
> Run the following command to view real-time transfer statistics:
>
> ```bash
> quantumsync stats --live
> ```
>
> The output displays:
>
> - Current upload and download speed
> - Number of files in the transfer queue
> - Estimated time remaining for queued transfers
>
> Press `Ctrl+C` to stop monitoring.

For additional information about network configuration, see [Network Settings](conditions-and-variables.md#network-settings). If you experience slow transfers, see [Slow sync performance](expandable-sections.md#issue-slow-performance) for optimization steps.
