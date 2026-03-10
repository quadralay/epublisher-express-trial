<!-- markers:{"Keywords": "settings, configuration, preferences, bandwidth, notifications, proxy, admin", "Description": "Configure Quantum Sync preferences including sync behavior, bandwidth limits, and notifications.", "IndexMarker": "settings:configuring,configuration:preferences"}; #settings -->
## Settings

$ProductName; $Version; provides extensive configuration options to customize sync behavior for your environment. Access settings through the system tray icon (Windows and Linux) or menu bar application (macOS).

<!-- marker:IndexMarker="settings:general" ; #general-settings -->
### General Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Start on login | Launch $ProductName; automatically when you sign in | Enabled |
| Show notifications | Display alerts for sync completion and errors | Enabled |
| Language | Application interface language | System default |
| Update channel | Receive stable or beta updates | Stable |
| Usage analytics | Share anonymous usage data to improve the product | Disabled |

<!-- marker:IndexMarker="settings:sync,bandwidth:limiting" ; #sync-settings -->
### Sync Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Sync folder location | Local directory for synchronized files | `Documents/$ProductName;` |
| Bandwidth limit (upload) | Maximum upload speed in KB/s (0 = unlimited) | 0 |
| Bandwidth limit (download) | Maximum download speed in KB/s (0 = unlimited) | 0 |
| Pause sync on battery | Stop syncing when laptop is on battery power | Disabled |
| Ignore file patterns | Files matching these patterns will not sync | `.tmp`, `~*` |

<!-- marker:IndexMarker="settings:network,proxy:configuration" ; #network-settings -->
### Network Settings

Configure proxy servers and network preferences for environments with restricted internet access.

| Setting | Description |
|---------|-------------|
| Proxy type | None, HTTP, SOCKS5, or system proxy |
| Proxy server | Hostname or IP address of proxy server |
| Proxy port | Port number for proxy connection |
| Proxy authentication | Username and password if required |

<!-- condition:online_only -->
> **Tip:** If your organization uses a proxy server, select **System proxy** to inherit your operating system's proxy configuration automatically.
<!-- /condition -->

<!-- condition:advanced -->
<!-- marker:IndexMarker="settings:administrator,enterprise:deployment" ; #admin-settings -->
### Administrator Settings

The following settings are available only to users with administrator privileges or when $ProductName; is deployed through enterprise management tools.

| Setting | Description | Impact |
|---------|-------------|--------|
| Enforce encryption | Require zero-knowledge encryption for all users | High |
| Disable sharing | Prevent users from sharing files externally | Medium |
| Audit logging | Log all file operations to a central server | Low |
| Remote wipe | Enable the ability to erase sync folders remotely | High |
| Password policy | Enforce minimum password complexity requirements | Medium |
| Session timeout | Automatically sign out inactive users after a specified period | Low |

#### Deploying Configuration Policies

Enterprise administrators can deploy settings to managed devices using configuration profiles:

1. Create a JSON policy file with the desired settings:

   ```json
   {
     "enforce_encryption": true,
     "disable_sharing": false,
     "audit_logging": true,
     "session_timeout_minutes": 480
   }
   ```

2. Distribute the policy file through your MDM solution
3. $ProductName; applies the policy on the next client restart

Contact your IT administrator or $SupportEmail; for assistance with enterprise deployment options.
<!-- /condition -->

<!-- condition:print_only -->
### Additional Resources

For the most current settings documentation, visit quantumsync.example/docs/settings.
<!-- /condition -->
