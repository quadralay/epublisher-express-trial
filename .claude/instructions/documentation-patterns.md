# Documentation Patterns

Project-specific Markdown++ patterns for ePublisher Express trial documentation.

## Glossaries

Use GlossaryTerm and GlossaryDef styles with dual anchors for each term:

```markdown
<!-- style:GlossaryTerm; #gloss-term-{term} -->
### {Term}:

<!-- style:GlossaryDef; #gloss-def-{term} -->
Definition text here.
```

**Example:**
```markdown
<!-- style:GlossaryTerm; #gloss-term-conflict -->
### Conflict:

<!-- style:GlossaryDef; #gloss-def-conflict -->
A situation where the same file has been modified on multiple devices.
```

**Cross-reference pattern:** `[Conflicts](#gloss-term-conflict)`

## Troubleshooting Issue Sections

Use the Issue style for searchable troubleshooting entries:

```markdown
<!-- style:Issue; #issue-{slug} -->
#### {Issue Title}

{Description of the problem and solution steps}
```

**Example:**
```markdown
<!-- style:Issue; #issue-files-not-syncing -->
#### Files not syncing

If files in your sync folder are not uploading or downloading:

- Check that you are connected to the internet
- Verify $ProductName; is running (look for the icon in your system tray)
- Ensure you have not paused synchronization
- Check available storage in your cloud account
```
