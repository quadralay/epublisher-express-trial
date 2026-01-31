---
title: Create Quantum Sync Sample Documentation
type: feat
date: 2026-01-30
---

# Create Quantum Sync Sample Documentation

## Overview

Replace the legacy Source Docs in the ePublisher Express Trial Project with streamlined "Quantum Sync" sample documentation demonstrating Markdown++ features for both Reverb 2.0 and PDF output.

**Brainstorm reference:** `docs/brainstorms/2026-01-30-trial-source-docs-brainstorm.md`

## Problem Statement / Motivation

The legacy Source Docs are dated, cluttered, and use multiple formats (FrameMaker, DITA, Word, Markdown). Trial users need a clean, modern example that:

1. Showcases Markdown++ authoring capabilities
2. Demonstrates attractive Reverb 2.0 output
3. Shows professional PDF generation
4. Uses clearly fictional content (not confused with training materials)

## Proposed Solution

Create a 7-topic "Quantum Sync" documentation set:

```
latest/local-express-trial-project/
└── ePublisher Express Trial Project/
    └── Source-Docs/
        ├── quantum-sync.md          # Master file (Title ===, includes)
        ├── topics/
        │   ├── overview.md          # Markers, aliases
        │   ├── getting-started.md   # Lists, conditions, content islands
        │   ├── features.md          # Multiline table
        │   ├── settings.md          # Variables, conditions
        │   ├── sync-modes.md        # Cross-references, tables
        │   ├── troubleshooting.md   # Code fences, blockquotes
        │   └── glossary.md          # Definition-style content
        └── images/
            └── quantum-sync-architecture.png  # Placeholder diagram
```

## Technical Considerations

### Markdown++ Syntax Rules

**From documented learnings:**
- List indentation: 2 spaces for bullets, 3 for numbered items
- Style comments must match content indentation exactly
- Avoid double bold markers (`****`)
- Include paths use forward slashes: `topics/overview.md`

### Heading Hierarchy

| File | Top Heading | Purpose |
|------|-------------|---------|
| `quantum-sync.md` | Title (`===`) | Document root |
| All topics | H2 (`##`) | Section starts |

### Feature Distribution Matrix

| Topic | Primary Feature | Secondary Features |
|-------|-----------------|-------------------|
| `quantum-sync.md` | Include directives | Document structure |
| `overview.md` | Markers (Keywords, Description) | Aliases, intro paragraphs |
| `getting-started.md` | Ordered lists | Content islands (tips), conditions |
| `features.md` | Multiline table | Lists in cells |
| `settings.md` | Variables | Conditions (admin/user) |
| `sync-modes.md` | Standard tables | Cross-reference aliases |
| `troubleshooting.md` | Code fences | Blockquote callouts |
| `glossary.md` | Definition formatting | Cross-reference links |

### Variables to Define

| Variable | Value | Usage |
|----------|-------|-------|
| `$ProductName;` | Quantum Sync | Throughout all topics |
| `$Version;` | 3.0 | Version references |
| `$SupportEmail;` | support@quantumsync.example | Contact info |

### Conditions to Define

| Condition | Purpose | Where Used |
|-----------|---------|------------|
| `print_only` | Content shown only in PDF | Troubleshooting (page references) |
| `online_only` | Content shown only in Reverb | Getting started (video link placeholder) |
| `advanced` | Advanced features content | Settings (admin options) |

## Content Outlines

### quantum-sync.md (Master File)
```
- Title: "Quantum Sync Documentation"
- Intro paragraph (2-3 sentences)
- Include directives for all 7 topics
- ~15-20 lines total
```

### topics/overview.md (~40 lines)
```
- H2: Overview with alias (#overview)
- Markers: Keywords="quantum sync, cloud storage, file synchronization"
- Markers: Description="Learn about Quantum Sync features"
- Product intro (2 paragraphs)
- Key benefits list (3-4 items)
- Use $ProductName; variable
```

### topics/getting-started.md (~50 lines)
```
- H2: Getting Started with alias (#getting-started)
- Prerequisites list (3 items)
- Ordered setup steps (5 steps)
- Tip callout (blockquote content island)
- Condition: online_only for "Watch the video" placeholder
```

### topics/features.md (~60 lines)
```
- H2: Features with alias (#features)
- Brief intro paragraph
- Multiline table with 4-5 features:
  - Feature name | Description with bullet list
  - Include: Real-time sync, Version history, Sharing, Encryption
```

### topics/settings.md (~45 lines)
```
- H2: Settings with alias (#settings)
- Standard settings table (5 rows)
- Condition: advanced for admin-only settings section
- Use $ProductName; and $Version; variables
```

### topics/sync-modes.md (~40 lines)
```
- H2: Sync Modes with alias (#sync-modes)
- Three modes: Automatic, Manual, Selective
- Standard table comparing modes
- Cross-reference to troubleshooting: [Troubleshooting](#troubleshooting)
```

### topics/troubleshooting.md (~50 lines)
```
- H2: Troubleshooting with alias (#troubleshooting)
- Common issues list (3-4 items)
- Code fence: CLI diagnostic command
- Blockquote: Note callout
- Condition: print_only for "See page X" reference
- Link to glossary for terms
```

### topics/glossary.md (~35 lines)
```
- H2: Glossary with alias (#glossary)
- Definition list format (6-8 terms)
- Terms: Sync, Conflict, Delta, Encryption, etc.
- Cross-reference links back to relevant sections
```

### images/quantum-sync-architecture.png
```
- Simple placeholder diagram
- Can be created with text describing architecture
- Or use a simple flowchart image
```

## Acceptance Criteria

### Functional Requirements

- [x] Master file `quantum-sync.md` includes all 7 topics
- [x] All topics use correct heading hierarchy (H2 start)
- [x] Markers present on all topic headings (Keywords at minimum)
- [x] Variables used in at least 3 topics ($ProductName;, $Version;, $SupportEmail;)
- [x] Conditions used in at least 2 topics (online_only, advanced, print_only)
- [x] Multiline table in features.md with bullet lists in cells
- [x] Cross-references link between topics correctly
- [x] At least one placeholder image included (SVG diagram)

### Markdown++ Syntax Compliance

- [x] Include paths use correct format: `<!--include:topics/filename.md-->`
- [x] Markers use JSON format: `<!--markers:{"Keywords": "..."}-->`
- [x] Conditions properly closed: `<!--condition:name-->...<!--/condition-->`
- [x] Variables end with semicolon: `$ProductName;`
- [x] List indentation follows rules (2 spaces bullets, 3 spaces numbered)

### Output Quality

- [ ] Generates successfully in ePublisher Express
- [ ] Reverb 2.0 output navigable and properly styled
- [ ] PDF output has correct structure and formatting
- [ ] TOC reflects heading hierarchy correctly
- [ ] Search finds content by keywords

## Success Metrics

- Total content: 300-400 lines across all files
- Generation time: Under 30 seconds
- User can explore output in under 2 minutes
- All 5 key Markdown++ features demonstrated visibly

## Dependencies & Risks

**Dependencies:**
- Express Trial stationery must support standard blockquote styling
- Variables window in ePublisher must have values configured (or document how)

**Risks:**
| Risk | Mitigation |
|------|------------|
| Custom styles not in stationery | Use only standard Markdown formatting |
| Include paths platform-dependent | Test on Windows and document format |
| Variables not pre-configured | Add setup instructions or use project-level variables |

## Implementation Sequence

1. Create directory structure under `latest/local-express-trial-project/`
2. Write master file `quantum-sync.md` with includes
3. Write topics in order: overview → getting-started → features → settings → sync-modes → troubleshooting → glossary
4. Create placeholder image
5. Test generation in ePublisher Express
6. Verify Reverb 2.0 and PDF output
7. Document any required variable/condition configuration

## References & Research

### Internal References

- Brainstorm: `docs/brainstorms/2026-01-30-trial-source-docs-brainstorm.md`
- Legacy structure: `legacy/local-express-trial-project/ePublisher Express Trial Project/Source Docs/Markdown/`
- Current guide pattern: `latest/online-trial-guide/express-trial/express-trial-guide.md`

### Documented Learnings

- List indentation rules: `/c/Projects/epublisher-docs/docs/solutions/syntax-issues/list-indentation-and-marker-fixes.md`
- Style comment alignment: `/c/Projects/epublisher-docs/docs/solutions/syntax-issues/style-comment-content-alignment.md`

### Markdown++ Syntax Reference

- Include directives: `<!--include:path/to/file.md-->`
- Markers: `<!--markers:{"Keywords": "value", "Description": "value"}-->`
- Conditions: `<!--condition:name-->content<!--/condition-->`
- Variables: `$VariableName;`
- Aliases: `<!-- #anchor-name -->`
- Multiline tables: `<!-- multiline -->` before table
