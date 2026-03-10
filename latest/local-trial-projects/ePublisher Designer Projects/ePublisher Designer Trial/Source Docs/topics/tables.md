<!-- markers:{"Keywords": "features, real-time sync, version history, sharing, encryption, collaboration, offline access", "Description": "Comprehensive overview of Quantum Sync features including sync, sharing, and security capabilities."}; #features -->
## Features

$ProductName; $Version; includes a comprehensive set of features designed for both individual users and enterprise teams. This section provides detailed information about each major capability.

<!-- #core-capabilities -->
### Core Capabilities

<!-- multiline ; marker:IndexMarker="synchronization:real-time,version history,sharing:secure,encryption:end-to-end,offline access" -->
| Feature | Description |
|---------|-------------|
| **Real-Time Sync** | Files synchronize across all connected devices within seconds of saving. |
|                    | |
|                    | - Detects changes instantly using file system watchers |
|                    | - Transmits only changed portions of files (delta sync) |
|                    | - Works in the background with minimal CPU and memory usage |
|                    | - Pauses automatically on metered connections |
| | |
| **Version History** | Access previous versions of any file for up to 180 days. |
|                     | |
|                     | - Restore deleted files within the retention period |
|                     | - Compare versions side-by-side |
|                     | - Download specific versions without overwriting current file |
|                     | - Extended retention available for enterprise accounts |
| | |
| **Secure Sharing** | Share files and folders with internal and external collaborators. |
|                    | |
|                    | - Password-protect shared links |
|                    | - Set expiration dates for temporary access |
|                    | - Control permissions: view-only, comment, or edit |
|                    | - Track who accessed shared content |
| | |
| **End-to-End Encryption** | All data is encrypted using industry-standard algorithms. |
|                           | |
|                           | - AES-256 encryption for data at rest |
|                           | - TLS 1.3 for data in transit |
|                           | - Optional client-side encryption (zero-knowledge mode) |
|                           | - SOC 2 Type II certified infrastructure |
| | |
| **Offline Access** | Continue working without an internet connection. |
|                    | |
|                    | - Mark files and folders for offline availability |
|                    | - Changes queue and sync when connection resumes |
|                    | - Conflict detection for concurrent offline edits |
| | |

<!-- marker:IndexMarker="platform support,system requirements" ; #platform-support -->
### Platform Support

$ProductName; runs natively on all major operating systems:

| Platform | Minimum Version | Architecture | Installer |
|:---------|:---------------:|:------------:| ---------:|
| Windows  | 10 (1903+)      | 64-bit       | `.exe`    |
| macOS    | 12 Monterey     | Universal    | `.dmg`    |
| Ubuntu   | 20.04 LTS       | x86_64       | `.deb`    |
| Fedora   | 36              | x86_64       | `.rpm`    |
| iOS      | 16              | ARM          | App Store |
| Android  | 12              | ARM/x86      | Play Store|

<!-- #plan-comparison -->
### Feature Comparison by Plan

Not all features are available on every subscription tier. The following table summarizes availability across plans.

<!-- multiline -->
| Capability | Personal | Team | Enterprise |
|:-----------|:--------:|:----:|:----------:|
| Real-time sync | Yes | Yes | Yes |
| | | | |
| Storage | 100 GB | 1 TB per user | Unlimited |
| | | | |
| Version history | 30 days | 90 days | 180 days |
|                 | | | Custom retention available |
| | | | |
| Sharing | View-only links | Full permissions | Full permissions |
|         | | | Audit logging |
| | | | |
| Encryption | In-transit | In-transit | In-transit |
|            | At-rest   | At-rest   | At-rest |
|            | | | Zero-knowledge option |
| | | | |
| Offline access | 5 GB | 50 GB | Unlimited |
| | | | |
| Support | Community forums | Email support | Dedicated account manager |
|         | | Business hours | 24/7 priority response |
| | | | |

Contact $SupportEmail; for information about upgrading your account.

### API Access

<!-- condition:advanced -->

<!-- marker:IndexMarker="API:overview,command line:integration" ; #api-access -->
#### REST API

$ProductName; provides a REST API for programmatic access to sync operations. Common use cases include:

1. Automating file uploads from CI/CD pipelines
2. Monitoring sync status across multiple devices
3. Managing shared links and permissions

#### CLI Integration

The `quantumsync` command-line tool supports all API operations:

```bash
# Upload a file
quantumsync upload ./report.pdf --folder "/Reports/2026"

# List recent changes
quantumsync changes --since "2026-01-01" --format json

# Create a shared link
quantumsync share "/Reports/2026/report.pdf" --expires 7d --password
```

<!-- /condition -->
