---
date: 2026-01-30
topic: trial-source-docs
---

# Update Source Documents for ePublisher Express Trial Project

## What We're Building

Replace the dated, cluttered legacy source documents in the ePublisher Express Trial Project with a streamlined Markdown++ sample that showcases Reverb 2.0 and PDF-XSL-FO output capabilities.

The new sample is a fictional "Quantum Sync" product documentation set—professional, clearly fictional, and designed to demonstrate key Markdown++ features without being confused with training materials.

## Why This Approach

**Considered alternatives:**
1. **Update existing content** - Rejected: Legacy content is fragmented across FrameMaker, DITA, Word, and Markdown. Starting fresh is cleaner.
2. **Minimal single-file demo** - Rejected: Doesn't showcase include directives or document composition.
3. **Comprehensive 15+ topic set** - Rejected: Over-engineered for a trial; takes too long to generate.

**Chosen: Moderate single-master structure (6-8 topics)**
- Shows include-based composition pattern
- Demonstrates key Markdown++ features without overwhelming
- Produces attractive, navigable output for both Reverb and PDF
- Quick to process, easy to explore

## Key Decisions

### Content Theme: Generic Product Documentation
Fictional "Quantum Sync" cloud connectivity product with features, settings, and troubleshooting. Modern-sounding but clearly fictional.

### Structure: Single Master with Topic Includes
```
Source-Docs/
├── quantum-sync.md          # Master file
└── topics/
    ├── overview.md
    ├── getting-started.md
    ├── features.md
    ├── settings.md
    ├── sync-modes.md
    ├── troubleshooting.md
    └── glossary.md
```

### Markdown++ Features to Demonstrate
| Feature | Where Used |
|---------|-----------|
| Include directives | Master file composing topics |
| Markers (Keywords, Description) | All major headings |
| Multiline tables | Features topic (rich cells) |
| Conditions | Settings (admin/user), Troubleshooting (platform) |
| Content islands | Getting Started (tips), Troubleshooting (notes) |
| Custom aliases | Cross-topic linking |
| Variables | Product name throughout |

### Content Guidelines
- Short topics: 30-60 lines each
- Professional tone, not placeholder text
- Each topic focuses on 1-2 Markdown++ features
- Clear visual hierarchy for attractive output

### Out of Scope (Separate Task)
- Reverb skin/Chrome changes to match ePublisher online help
- Modifications to the .wrp project file configuration

## Open Questions

1. Should variables be defined in a separate file or inline? (Check ePublisher docs for convention)
2. Which specific conditions should be created? (Suggested: `admin_only`, `windows`, `mac`)
3. Any preference for color scheme or styling in the content islands?

## Next Steps

→ `/workflows:plan` for implementation details including:
- Specific topic content outlines
- Markdown++ syntax for each feature
- File creation sequence
