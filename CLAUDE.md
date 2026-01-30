# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **documentation-only project** for the ePublisher Express trial. It contains tutorial guides written in Markdown++ format.

- **Type:** Static documentation / trial guides
- **Technology:** Markdown++ (backward compatible with Markdown)
- **Primary File:** `express-trial/express-trial-guide.md`

## Project Structure

```
epublisher-express-trial/
├── express-trial/                    # NEW: Minimal quick-start guide
│   ├── express-trial-guide.md        # ~60 lines, 2 steps + done
│   └── images/                       # Product-prefixed screenshots
│       ├── express-doc-manager.png
│       └── express-generate-button.png
├── legacy/                           # ARCHIVED: Original verbose guide
│   ├── express-trial-guide.md        # 507 lines (reference only)
│   └── images/                       # 40 PNG screenshots
├── docs/
│   └── plans/                        # Implementation plans
└── TRIAL-GUIDE-TEMPLATE.md           # Pattern for future guides
```

## Active Guide: express-trial/

The new guide follows a ruthlessly minimal 2-step structure optimized for time-to-value:

1. **Step 1: Add Documents** - Drag Markdown++ files to Document Manager
2. **Step 2: Generate** - Click Generate All, explore the output
3. **Done** - Single CTA to Designer for customization

### Markdown++ Features Used

- **Aliases:** `<!-- #anchor-name -->` on all significant headings
- **Markers:** Keywords and Description metadata in header
- **Multiline tables:** Feature exploration table with complex cells
- **Content islands:** Blockquote tip callout
- **Conditions:** AI features showcase (optional display)

### Design Principles

- Under 80 lines total
- 2 screenshots maximum
- No welcome/value proposition (users already committed)
- Single CTA at completion
- Link to full docs for details

## Legacy Guide: legacy/

The original 507-line guide is archived for reference. It includes:
- 4 detailed hands-on TASKs
- 40 screenshots
- Support for Word, FrameMaker, DITA (now focused on Markdown++ only)

## Scalability

Future trial guides (AutoMap, Designer) will follow the same pattern:
- Product-prefixed image names: `automap-*.png`, `designer-*.png`
- Self-contained directories: `automap-trial/`, `designer-trial/`
- Same 2-step + done structure

## External References

- Full documentation: https://static.webworks.com/docs/epublisher/latest/help/
- Markdown++ syntax: https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.01.html
