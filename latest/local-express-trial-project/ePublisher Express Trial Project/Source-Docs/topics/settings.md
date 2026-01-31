<!-- markers:{"Keywords": "settings, configuration, preferences, bandwidth, notifications, admin", "Description": "Configure Quantum Sync preferences including sync behavior, bandwidth limits, and notifications"}; #settings -->
## Settings

$ProductName; $Version; provides extensive configuration options to customize sync behavior for your environment. Access settings through the system tray icon or menu bar application.

### General Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Start on login | Launch $ProductName; automatically when you sign in | Enabled |
| Show notifications | Display alerts for sync completion and errors | Enabled |
| Language | Application interface language | System default |
| Update channel | Receive stable or beta updates | Stable |
| Usage analytics | Share anonymous usage data to improve the product | Disabled |

### Sync Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Sync folder location | Local directory for synchronized files | Documents/$ProductName; |
| Bandwidth limit (upload) | Maximum upload speed in KB/s (0 = unlimited) | 0 |
| Bandwidth limit (download) | Maximum download speed in KB/s (0 = unlimited) | 0 |
| Pause sync on battery | Stop syncing when laptop is on battery power | Disabled |
| Ignore file patterns | Files matching these patterns are not synced | .tmp, ~* |

### Network Settings

Configure proxy servers and network preferences for environments with restricted internet access.

| Setting | Description |
|---------|-------------|
| Proxy type | None, HTTP, SOCKS5, or system proxy |
| Proxy server | Hostname or IP address of proxy server |
| Proxy port | Port number for proxy connection |
| Proxy authentication | Username and password if required |

<!-- condition:advanced -->
### Administrator Settings

The following settings are only available to users with administrator privileges or when $ProductName; is deployed via enterprise management tools.

| Setting | Description |
|---------|-------------|
| Enforce encryption | Require zero-knowledge encryption for all users |
| Disable sharing | Prevent users from sharing files externally |
| Audit logging | Log all file operations to a central server |
| Remote wipe | Enable ability to erase sync folders remotely |

Contact your IT administrator or $SupportEmail; for assistance with enterprise deployment options.
<!-- /condition -->
