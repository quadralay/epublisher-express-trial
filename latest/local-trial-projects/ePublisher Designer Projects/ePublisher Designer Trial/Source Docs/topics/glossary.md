<!-- markers:{"Keywords": "glossary, definitions, terms, terminology, reference", "Description": "Definitions of technical terms used throughout the Quantum Sync documentation."}; #glossary -->
## Glossary

[glossary]: #glossary "Glossary"

This glossary defines technical terms used throughout the $ProductName; documentation.

<!-- style:Glossary Term ; marker:IndexMarker="glossary:conflict" ; #gloss-term-conflict -->
### Conflict:

[gloss-term-conflict]: #gloss-term-conflict "Conflict"

<!-- style:Glossary Def ; #gloss-def-conflict -->
A situation where the same file is modified on two or more devices before synchronization completes. $ProductName; resolves conflicts by keeping both versions and adding a timestamp to the filename of the secondary copy. See [Troubleshooting][issue-sync-conflicts] for conflict resolution steps.

[gloss-def-conflict]: #gloss-def-conflict "Conflict definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:delta sync" ; #gloss-term-delta-sync -->
### Delta Sync:

[gloss-term-delta-sync]: #gloss-term-delta-sync "Delta Sync"

<!-- style:Glossary Def ; #gloss-def-delta-sync -->
A synchronization technique that transmits only the changed portions of a file rather than the entire file. Delta sync significantly reduces bandwidth usage and sync time, especially for large files with small modifications.

[gloss-def-delta-sync]: #gloss-def-delta-sync "Delta Sync definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:encryption,encryption:definition" ; #gloss-term-encryption -->
### Encryption:

[gloss-term-encryption]: #gloss-term-encryption "Encryption"

<!-- style:Glossary Def ; #gloss-def-encryption -->
The process of encoding data so that only authorized parties can read it. $ProductName; uses AES-256 encryption for data at rest and TLS 1.3 for data in transit. See [End-to-End Encryption][core-capabilities] for details.

[gloss-def-encryption]: #gloss-def-encryption "Encryption definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:ignore pattern" ; #gloss-term-ignore-pattern -->
### Ignore Pattern:

[gloss-term-ignore-pattern]: #gloss-term-ignore-pattern "Ignore Pattern"

<!-- style:Glossary Def ; #gloss-def-ignore-pattern -->
A file name pattern that tells $ProductName; to skip matching files during synchronization. Common ignore patterns include `*.tmp`, `*.log`, and `node_modules/`. Configure ignore patterns in [Sync Settings][sync-settings].

[gloss-def-ignore-pattern]: #gloss-def-ignore-pattern "Ignore Pattern definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:metered connection" ; #gloss-term-metered-connection -->
### Metered Connection:

[gloss-term-metered-connection]: #gloss-term-metered-connection "Metered Connection"

<!-- style:Glossary Def ; #gloss-def-metered-connection -->
A network connection with limited data allowance, such as cellular data or some Wi-Fi hotspots. $ProductName; can detect metered connections and pause automatic sync to avoid unexpected data charges.

[gloss-def-metered-connection]: #gloss-def-metered-connection "Metered Connection definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:retention period" ; #gloss-term-retention-period -->
### Retention Period:

[gloss-term-retention-period]: #gloss-term-retention-period "Retention Period"

<!-- style:Glossary Def ; #gloss-def-retention-period -->
The length of time that $ProductName; keeps previous versions of your files. The retention period varies by plan: 30 days for Personal, 90 days for Team, and 180 days for Enterprise. See the [Plan Comparison][plan-comparison] for details.

[gloss-def-retention-period]: #gloss-def-retention-period "Retention Period definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:selective sync" ; #gloss-term-selective-sync -->
### Selective Sync:

[gloss-term-selective-sync]: #gloss-term-selective-sync "Selective Sync"

<!-- style:Glossary Def ; #gloss-def-selective-sync -->
A feature that allows you to choose which cloud folders sync to each device. Files in unselected folders remain in your cloud storage but do not consume local disk space. See [Selective Sync][selective-sync] for configuration instructions.

[gloss-def-selective-sync]: #gloss-def-selective-sync "Selective Sync definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:sync folder" ; #gloss-term-sync-folder -->
### Sync Folder:

[gloss-term-sync-folder]: #gloss-term-sync-folder "Sync Folder"

<!-- style:Glossary Def ; #gloss-def-sync-folder -->
The local directory where $ProductName; stores synchronized files. By default, this is located in your Documents folder. You can change the sync folder location in [Sync Settings][sync-settings].

[gloss-def-sync-folder]: #gloss-def-sync-folder "Sync Folder definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:version history" ; #gloss-term-version-history -->
### Version History:

[gloss-term-version-history]: #gloss-term-version-history "Version History"

<!-- style:Glossary Def ; #gloss-def-version-history -->
A record of previous versions of each file, maintained automatically by $ProductName;. You can restore or download any previous version within the [retention period][gloss-term-retention-period]. See [Version History][core-capabilities] for retention policy details.

[gloss-def-version-history]: #gloss-def-version-history "Version History definition"

<!-- style:Glossary Term ; marker:IndexMarker="glossary:zero-knowledge encryption" ; #gloss-term-zero-knowledge -->
### Zero-Knowledge Encryption:

[gloss-term-zero-knowledge]: #gloss-term-zero-knowledge "Zero-Knowledge Encryption"

<!-- style:Glossary Def ; #gloss-def-zero-knowledge -->
A security model where the service provider cannot decrypt your files, even if compelled by legal authority. Only you hold the encryption keys. $ProductName; offers zero-knowledge encryption as an optional setting for organizations with strict compliance requirements. See [Security Model][key-benefits] for an overview.

[gloss-def-zero-knowledge]: #gloss-def-zero-knowledge "Zero-Knowledge Encryption definition"

<!--
  Cross-file slug definitions (pattern-file artifact).

  The Designer Trial source docs are pattern files for modular development.
  Each topic file is registered as a separate source document in the .wep, not
  assembled via includes. So `[Text][slug]` cross-references need each outgoing
  slug defined locally per CommonMark scope rules. In a production setup where
  topic files are assembled via include directives, these local defs would not
  be needed — each target file's triple already places the slug in
  document-global scope after Phase 1 assembly. Maintaining this block by hand
  is not the expected real-world workflow.
-->

[issue-sync-conflicts]: expandable-sections.md#issue-sync-conflicts "Sync conflicts"
[core-capabilities]: tables.md#core-capabilities "Core Capabilities"
[sync-settings]: conditions-and-variables.md#sync-settings "Sync Settings"
[plan-comparison]: tables.md#plan-comparison "Feature Comparison by Plan"
[selective-sync]: content-islands.md#selective-sync "Selective Sync"
[key-benefits]: headings-and-text.md#key-benefits "Key Benefits"
