---
title: Update Express Trial Guide Source Document References
type: docs
date: 2026-01-30
---

# Update Express Trial Guide Source Document References

Update `express-trial/express-trial-guide.md` to clearly reference the sample source documents installed with ePublisher Express and simplify the user experience by directing users to a single entry file.

## Problem Statement

The current trial guide has several gaps that confuse users:

1. **No path to source documents** - Users don't know where sample files are located on their Windows system (`Documents\ePublisher Express Projects\ePublisher Express Trial Project`)
2. **No handling of returning users** - First-time users see auto-open; returning users must manually open the `.wrp` file, but this isn't explained
3. **Vague file references** - "Drag your Markdown++ files" doesn't specify which files or where to find them
4. **Overwhelming output** - 23 source files generate complex output; users should add only the single entry file `Exploring ePublisher.md`

## Acceptance Criteria

- [x] Add conditional instructions for first-time vs. returning users
- [x] Include explicit Windows path to sample source documents
- [x] Change instructions to add only `Exploring ePublisher.md` (not all 23 files)
- [x] Stay within 100-line limit (currently 82 lines)
- [x] Maintain existing anchors and Markdown++ features

## Context

**Key files:**
- `express-trial/express-trial-guide.md` (82 lines) - Active guide to update
- `ePublisher Express Trial Project/Source Docs/Markdown/Exploring ePublisher.md` - Single entry file that includes all topics

**Installation details:**
- Project folder: `Documents\ePublisher Express Projects\ePublisher Express Trial Project`
- Project file: `ePublisher Express Trial Project.wrp`
- Source docs: `Source Docs\Markdown\` subfolder

**Constraints:**
- Line limit: ~100 lines
- Screenshots: max 2 (currently 2)

## MVP

### express-trial/express-trial-guide.md

Update Step 1 (approximately lines 7-19) with:

```markdown
<!-- #add-documents -->
## Step 1: Add Documents

The **ePublisher Express Trial Project** opens automatically on first launch.

> **Returning user?** Choose **File > Open** and navigate to:
> `Documents\ePublisher Express Projects\ePublisher Express Trial Project\ePublisher Express Trial Project.wrp`

Add the sample source document to the Document Manager:

1. Click **View** > **Project Directory**
2. Open `Source Docs` > `Markdown`
3. Drag `Exploring ePublisher.md` to the Document Manager

![Document Manager with drag target](images/express-doc-manager.png)

> **Tip:** This single file includes all the sample topics. Markdown++ uses `<!--include:-->` directives to compose documents.
```

**Changes:**
- Added auto-open statement for first-time users
- Added blockquote callout for returning users with explicit .wrp path
- Changed from "drag each .md file" to "drag `Exploring ePublisher.md`"
- Updated tip to explain the include directive pattern

## References

- Current guide: `express-trial/express-trial-guide.md:7-19`
- Sample entry file: `ePublisher Express Trial Project/Source Docs/Markdown/Exploring ePublisher.md`
- Design principles: CLAUDE.md (under 100 lines, 2 screenshots max)
