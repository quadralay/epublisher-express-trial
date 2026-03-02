<!-- markers:{"Keywords": "glossary, definitions, terms, terminology, reference", "Description": "Definitions of technical terms used throughout the Quantum Sync documentation."}; #glossary -->
## Glossary

This glossary defines technical terms used throughout the $ProductName; documentation.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:conflict" ; #gloss-term-conflict -->
### Conflict:

<!-- style:Glossary Def ; #gloss-def-conflict -->
A situation where the same file is modified on two or more devices before synchronization completes. $ProductName; resolves conflicts by keeping both versions and adding a timestamp to the filename of the secondary copy. See [Troubleshooting](expandable-sections.md#issue-sync-conflicts) for conflict resolution steps.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:delta sync" ; #gloss-term-delta-sync -->
### Delta Sync:

<!-- style:Glossary Def ; #gloss-def-delta-sync -->
A synchronization technique that transmits only the changed portions of a file rather than the entire file. Delta sync significantly reduces bandwidth usage and sync time, especially for large files with small modifications.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:encryption,encryption:definition" ; #gloss-term-encryption -->
### Encryption:

<!-- style:Glossary Def ; #gloss-def-encryption -->
The process of encoding data so that only authorized parties can read it. $ProductName; uses AES-256 encryption for data at rest and TLS 1.3 for data in transit. See [End-to-End Encryption](tables.md#core-capabilities) for details.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:ignore pattern" ; #gloss-term-ignore-pattern -->
### Ignore Pattern:

<!-- style:Glossary Def ; #gloss-def-ignore-pattern -->
A file name pattern that tells $ProductName; to skip matching files during synchronization. Common ignore patterns include `*.tmp`, `*.log`, and `node_modules/`. Configure ignore patterns in [Sync Settings](conditions-and-variables.md#sync-settings).

<!-- style:Glossary Term ; marker:IndexMarker="glossary:metered connection" ; #gloss-term-metered-connection -->
### Metered Connection:

<!-- style:Glossary Def ; #gloss-def-metered-connection -->
A network connection with limited data allowance, such as cellular data or some Wi-Fi hotspots. $ProductName; can detect metered connections and pause automatic sync to avoid unexpected data charges.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:retention period" ; #gloss-term-retention-period -->
### Retention Period:

<!-- style:Glossary Def ; #gloss-def-retention-period -->
The length of time that $ProductName; keeps previous versions of your files. The retention period varies by plan: 30 days for Personal, 90 days for Team, and 180 days for Enterprise. See the [Plan Comparison](tables.md#plan-comparison) for details.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:selective sync" ; #gloss-term-selective-sync -->
### Selective Sync:

<!-- style:Glossary Def ; #gloss-def-selective-sync -->
A feature that allows you to choose which cloud folders sync to each device. Files in unselected folders remain in your cloud storage but do not consume local disk space. See [Selective Sync](content-islands.md#selective-sync) for configuration instructions.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:sync folder" ; #gloss-term-sync-folder -->
### Sync Folder:

<!-- style:Glossary Def ; #gloss-def-sync-folder -->
The local directory where $ProductName; stores synchronized files. By default, this is located in your Documents folder. You can change the sync folder location in [Sync Settings](conditions-and-variables.md#sync-settings).

<!-- style:Glossary Term ; marker:IndexMarker="glossary:version history" ; #gloss-term-version-history -->
### Version History:

<!-- style:Glossary Def ; #gloss-def-version-history -->
A record of previous versions of each file, maintained automatically by $ProductName;. You can restore or download any previous version within the [retention period](#gloss-term-retention-period). See [Version History](tables.md#core-capabilities) for retention policy details.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:zero-knowledge encryption" ; #gloss-term-zero-knowledge -->
### Zero-Knowledge Encryption:

<!-- style:Glossary Def ; #gloss-def-zero-knowledge -->
A security model where the service provider cannot decrypt your files, even if compelled by legal authority. Only you hold the encryption keys. $ProductName; offers zero-knowledge encryption as an optional setting for organizations with strict compliance requirements. See [Security Model](headings-and-text.md#key-benefits) for an overview.
