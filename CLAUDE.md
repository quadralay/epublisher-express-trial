# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **documentation-only project** for ePublisher trial experiences. It contains tutorial guides written in Markdown++ format and sample projects for Express and Designer trials.

- **Type:** Static documentation / trial guides
- **Technology:** Markdown++ (backward compatible with Markdown)
- **Primary File:** `latest/online-trial-guides/designer-trial/designer-trial-guide.md`

## Project Structure

```
epublisher-express-trial/
├── latest/                              # ACTIVE: Current versions
│   ├── local-trial-projects/            # Sample ePublisher projects
│   │   ├── ePublisher Designer Trial/   # Designer trial project
│   │   └── ePublisher Express Trial Project/  # Express trial project
│   └── online-trial-guides/             # Online quick-start guides
│       ├── designer-trial/
│       │   ├── designer-trial-guide.md  # ~212 lines, 5 steps + done + explore more
│       │   └── images/                  # Product-prefixed screenshots (designer-*)
│       └── express-trial/
│           ├── express-trial-guide.md   # ~140 lines, 2 steps + done + explore more
│           └── images/                  # Product-prefixed screenshots (express-*)
├── legacy/                              # ARCHIVED: Previous versions
│   ├── Source Docs/                     # Sample source docs (FrameMaker, DITA, Markdown)
│   └── online-express-trial-guide/      # Original verbose guide
│       ├── express-trial-guide.md       # 507 lines (reference only)
│       └── images/                      # 40 PNG screenshots
├── docs/
│   ├── brainstorms/                     # Feature brainstorming documents
│   ├── plans/                           # Implementation plans
│   └── prompts/                         # Prompt history for guide rewrite
└── .claude/
    └── instructions/                    # Claude authoring patterns
```

## Active Guides: latest/online-trial-guides/

Both guides use a dual-audience structure: fast activation for "just let me click" users, with deeper evaluation content for prospects deciding whether to buy.

**Designer Trial Guide (primary, 5 steps, ~212 lines):**
1. **Step 1: Open & Generate** - Launch project, observe Document Manager, generate, view output
2. **Step 2: Content Rules** - Variables and conditions customization
3. **Step 3: Brand Output** - SCSS colors and PDF cover
4. **Step 4: Style Designer** - Prototype inheritance and style properties
5. **Step 5: Multiple Targets** - Web Help vs PDF from same source
6. **Done** - Inspiring CTA with output screenshot
7. **Explore More** - What You Just Did, Try Features, Stationery, AutoMap, Product Family, AI Skills

**Express Trial Guide (2 steps, ~145 lines):**
1. **Step 1: Add Documents** - Drag Markdown++ files to Document Manager
2. **Step 2: Generate** - Click Generate All, explore the output
3. **Done** - CTA to Designer + bridge to Explore More
4. **Explore More** - What You Just Did, Try Features, Customize, Product Family, Designer, AutoMap

### Markdown++ Features Used

- **Aliases:** `<!-- #anchor-name -->` on all significant headings
- **Markers:** Keywords and Description metadata in header
- **Multiline tables:** Feature exploration table with complex cells
- **Content islands:** Blockquote tip callout
- **Conditions:** AI features showcase (optional display)

### Design Principles

- Core steps: Under 45 lines for Express (2 steps), under 75 lines for Designer (5 steps)
- Explore More: Up to 95 additional lines (evaluation depth)
- Total: 120-150 lines (Express) or 150-215 lines (Designer)
- Screenshots: 1-2 per step as needed for visual confirmation
- No welcome/value proposition (users already committed)
- CTA at Done bridges to Explore More for evaluators
- Format references (Word, FrameMaker, DITA) allowed in intro positioning and Explore More

## Legacy Content: legacy/

### legacy/online-express-trial-guide/
The original 507-line guide is archived for reference. It includes:
- 4 detailed hands-on TASKs
- 40 screenshots
- Support for Word, FrameMaker, DITA (now focused on Markdown++ only)

### legacy/Source Docs/
Contains legacy sample source documents in multiple formats (FrameMaker, DITA, Markdown).

## Scalability

Future trial guides (AutoMap) will follow the same dual-audience pattern:
- Product-prefixed image names: `automap-*.png`, `designer-*.png`
- Self-contained directories within `latest/`
- Step count varies by product (2 for Express, 5 for Designer)
- Each guide is fully standalone — no dependencies between guides

## Claude Instructions

Project-specific patterns are in `.claude/instructions/`:
- `documentation-patterns.md` - Glossary and Troubleshooting Issue styles
- `trial-guide-template.md` - Structure and guidelines for trial guides

For general Markdown++ syntax, use the `webworks-claude-skills:markdown-plus-plus` skill.

## External References

- Full documentation: https://static.webworks.com/docs/epublisher/latest/help/
- Markdown++ syntax: https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.01.html
