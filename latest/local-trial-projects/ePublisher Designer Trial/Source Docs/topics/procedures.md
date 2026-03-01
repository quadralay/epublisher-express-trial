<!-- markers:{"Keywords": "getting started, setup, installation, quickstart, prerequisites", "Description": "Step-by-step guide to installing and configuring Quantum Sync on your device.", "IndexMarker": "installation,setup:initial"}; #getting-started -->
## Getting Started

This guide walks you through the initial setup of $ProductName; on your device. The entire process takes approximately five minutes.

<!-- #prerequisites -->
### Prerequisites

Before you begin, ensure you have the following:

- A valid $ProductName; account (create one at quantumsync.example/signup)
- At least 500 MB of free disk space for the application
- An active internet connection for initial setup
- One of the following supported operating systems:
  - **Windows** — Windows 10 version 1903 or later (64-bit)
  - **macOS** — macOS 12 Monterey or later
    - Intel and Apple Silicon supported natively
  - **Linux** — Ubuntu 20.04+, Fedora 36+, or Debian 11+
    - `.deb` and `.rpm` packages available

### Installation

<!-- style:ProcedureTitle ; #installation -->
To install $ProductName; on your device:

1. **Download the installer**

   Visit quantumsync.example/download and select your operating system:
   - Windows: `QuantumSync-Setup.exe`
   - macOS: `QuantumSync.dmg`
   - Linux: `quantumsync_amd64.deb` or `quantumsync.rpm`

2. **Run the installer**

   <!-- condition:print_only -->
   Refer to the platform-specific instructions included in your download package.
   <!-- /condition -->

   <!-- condition:online_only -->
   Double-click the downloaded file and follow the on-screen prompts:
   - Accept the license agreement
   - Choose your installation directory
   - Select whether to start $ProductName; at login
   <!-- /condition -->

3. **Sign in to your account**

   When prompted, enter your email address and password. If you enabled two-factor authentication, enter your verification code.

4. **Select your sync folder**

   Choose the local folder where $ProductName; will store synchronized files. The default location is:

   ```
   Windows:  C:\Users\<username>\QuantumSync
   macOS:    ~/QuantumSync
   Linux:    ~/QuantumSync
   ```

5. **Configure initial sync**

   Select which existing cloud folders to sync to this device. You can change these settings later in [Settings](conditions-and-variables.md#settings).

> **Tip:** For the fastest initial sync, connect to a wired network. $ProductName; downloads large file sets significantly faster over Ethernet than Wi-Fi.

<!-- #verify-installation -->
### Verifying Your Installation

After installation, confirm that $ProductName; is running correctly:

1. Look for the $ProductName; icon in your system tray (Windows/Linux) or menu bar (macOS)
2. Click the icon to open the status panel
3. Verify the status reads **Connected** and your account email appears
4. Create a test file in your sync folder and confirm it appears at quantumsync.example/files

If the status shows **Disconnected** or **Error**, see [Troubleshooting](expandable-sections.md#troubleshooting) for solutions.

<!-- style:Heading 3 ; #command-line-verification -->
### Command-Line Verification

<!-- condition:advanced -->
Advanced users can verify the installation from the command line:

```bash
quantumsync --version
quantumsync --status
quantumsync --diagnose
```

The `--diagnose` command runs a connectivity test and reports any configuration issues. The output includes your client version, connection status, and sync folder location.
<!-- /condition -->

### Configuring Selective Sync

<!-- style:ProcedureTitle ; #configure-selective-sync -->
To choose which cloud folders sync to this device:

1. Open $ProductName; settings
2. Navigate to the **Selective Sync** tab
3. Review the list of cloud folders and their sizes
4. Clear the checkboxes for folders you want to exclude from this device
   - Excluded folders are removed from your local drive
   - Files remain safely stored in your cloud account
5. Click **Apply** to save your changes

$ProductName; frees the associated disk space immediately. To re-enable a folder, return to the Selective Sync tab and check the folder again.

### Next Steps

After installation, $ProductName; runs in the background and keeps your files synchronized automatically. To learn about available capabilities, see [Features](tables.md#features). To customize sync behavior, see [Settings](conditions-and-variables.md#settings).
