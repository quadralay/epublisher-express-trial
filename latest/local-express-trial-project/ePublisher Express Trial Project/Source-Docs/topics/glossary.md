<!--markers:{"Keywords": "glossary, definitions, terms, terminology, reference", "Description": "Definitions of technical terms used throughout the Quantum Sync documentation"} ; #glossary-->
## Glossary

This glossary defines technical terms used throughout the $ProductName; documentation.

<!--style:GlossaryTerm ; #term-conflict-->
### Conflict:

<!--style:GlossaryDef ; #def-conflict-->
A situation where the same file is modified on two or more devices before synchronization completes. $ProductName; resolves conflicts by keeping both versions and adding a timestamp to the filename of the secondary copy. See [Troubleshooting](#troubleshooting) for conflict resolution steps.

<!--style:GlossaryTerm ; #term-delta-sync-->
### Delta Sync:

<!--style:GlossaryDef ; #def-delta-sync-->
A synchronization technique that transmits only the changed portions of a file rather than the entire file. Delta sync significantly reduces bandwidth usage and sync time for large files with small modifications.

<!--style:GlossaryTerm ; #term-encryption-->
### Encryption:

<!--style:GlossaryDef ; #def-encryption-->
The process of encoding data so that only authorized parties can read it. $ProductName; uses AES-256 encryption for data at rest and TLS 1.3 for data in transit. See [Features](#features) for encryption details.

<!--style:GlossaryTerm ; #term-metered-connection-->
### Metered Connection:

<!--style:GlossaryDef ; #def-metered-connection-->
A network connection with limited data allowance, such as cellular data or some Wi-Fi hotspots. $ProductName; can detect metered connections and pause automatic sync to avoid unexpected data charges.

<!--style:GlossaryTerm ; #term-selective-sync-->
### Selective Sync:

<!--style:GlossaryDef ; #def-selective-sync-->
A feature that allows you to choose which folders sync to each device. Files in unselected folders remain in your cloud storage but do not consume local disk space. See [Sync Modes](#sync-modes) for configuration instructions.

<!--style:GlossaryTerm ; #term-sync-folder-->
### Sync Folder:

<!--style:GlossaryDef ; #def-sync-folder-->
The local directory where $ProductName; stores synchronized files. By default, this is located in your Documents folder. You can change the location in [Settings](#settings).

<!--style:GlossaryTerm ; #term-version-history-->
### Version History:

<!--style:GlossaryDef ; #def-version-history-->
A record of previous versions of each file, maintained automatically by $ProductName;. You can restore or download any previous version within the retention period. See [Features](#features) for retention policy details.

<!--style:GlossaryTerm ; #term-zero-knowledge-->
### Zero-Knowledge Encryption:

<!--style:GlossaryDef ; #def-zero-knowledge-->
A security model where $ProductName; cannot decrypt your files, even if required by law enforcement. Only you hold the encryption keys. This feature is available as an optional setting for users who require maximum privacy.
