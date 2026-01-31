<!--markers:{"Keywords": "glossary, definitions, terms, terminology, reference", "Description": "Definitions of technical terms used throughout the Quantum Sync documentation"} ; #glossary-->
## Glossary

This glossary defines technical terms used throughout the $ProductName; documentation.

<!--#conflict-->
**Conflict**
:   A situation where the same file is modified on two or more devices before synchronization completes. $ProductName; resolves conflicts by keeping both versions and adding a timestamp to the filename of the secondary copy. See [Troubleshooting](#troubleshooting) for conflict resolution steps.

<!--#delta-sync-->
**Delta Sync**
:   A synchronization technique that transmits only the changed portions of a file rather than the entire file. Delta sync significantly reduces bandwidth usage and sync time for large files with small modifications.

<!--#encryption-->
**Encryption**
:   The process of encoding data so that only authorized parties can read it. $ProductName; uses AES-256 encryption for data at rest and TLS 1.3 for data in transit. See [Features](#features) for encryption details.

<!--#metered-connection-->
**Metered Connection**
:   A network connection with limited data allowance, such as cellular data or some Wi-Fi hotspots. $ProductName; can detect metered connections and pause automatic sync to avoid unexpected data charges.

<!--#selective-sync-->
**Selective Sync**
:   A feature that allows you to choose which folders sync to each device. Files in unselected folders remain in your cloud storage but do not consume local disk space. See [Sync Modes](#sync-modes) for configuration instructions.

<!--#sync-folder-->
**Sync Folder**
:   The local directory where $ProductName; stores synchronized files. By default, this is located in your Documents folder. You can change the location in [Settings](#settings).

<!--#version-history-->
**Version History**
:   A record of previous versions of each file, maintained automatically by $ProductName;. You can restore or download any previous version within the retention period. See [Features](#features) for retention policy details.

<!--#zero-knowledge-->
**Zero-Knowledge Encryption**
:   A security model where $ProductName; cannot decrypt your files, even if required by law enforcement. Only you hold the encryption keys. This feature is available as an optional setting for users who require maximum privacy.
