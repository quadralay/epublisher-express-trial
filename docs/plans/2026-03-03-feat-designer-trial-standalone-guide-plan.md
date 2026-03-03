---
title: "feat: Make Designer Trial Guide Standalone"
type: feat
status: completed
date: 2026-03-03
origin: docs/brainstorms/2026-03-03-designer-trial-standalone-brainstorm.md
---

# feat: Make Designer Trial Guide Standalone

## Overview

Transform the Designer Trial Guide from a follow-on to the Express Trial Guide into the **primary entry point** for ePublisher evaluation users. The Designer trial provides a more complete picture of the custom publishing experience and should work for users who have never seen Express.

The current guide (132 lines, 3 steps, 0 screenshots) assumes users know how to open a project, generate output, and use the Document Manager. The rewrite adds a setup step, a Style Designer step, screenshots throughout, and repositions the intro for multi-authoring environments.

## Problem Statement / Motivation

ePublisher evaluation users are currently directed to the Express Trial Guide first, then the Designer Trial Guide as a follow-on. This creates friction — Designer is the more complete evaluation experience, but the guide assumes Express knowledge. Making the Designer guide standalone lets us direct evaluators there directly, giving them the full picture of ePublisher's customization capabilities in a single, self-contained experience.

## Proposed Solution

**Hybrid approach:** One brief "Open & Generate" step establishes the baseline, then 4 customization steps demonstrate Designer's value. This preserves Designer's customization-focused identity while ensuring first-time users have enough context. (see brainstorm: docs/brainstorms/2026-03-03-designer-trial-standalone-brainstorm.md)

### Structure: 5 Core Steps

| Step | Title | Purpose | New/Existing |
|------|-------|---------|--------------|
| 1 | Open & Generate | Launch project, observe Document Manager, generate Web Help, view output | **New** |
| 2 | Customize Content Rules | Variables (`ProductName`) + Conditions (`advanced`) | Existing (renumbered from Step 1) |
| 3 | Brand the Output | SCSS color change + PDF cover replacement | Existing (renumbered from Step 2) |
| 4 | Explore the Style Designer | Open Style Designer, observe [Prototype] inheritance, change a property, regenerate | **New** |
| 5 | Generate Multiple Targets | Switch to PDF target, generate, compare output | Existing (renumbered from Step 3) |

### Screenshot Plan

Placeholder image references will be written into the guide. Actual PNGs captured separately. All filenames use `designer-` prefix.

| Step | Screenshot | Filename | Shows |
|------|-----------|----------|-------|
| 1 | Document Manager with pre-loaded files | `designer-doc-manager.png` | Left panel showing 8 source documents in Help group |
| 1 | Generate button / output browser | `designer-generate-output.png` | Generate All button or the Reverb output in browser |
| 2 | Target Settings with variables | `designer-target-settings-variables.png` | Variables panel showing ProductName, Version, etc. |
| 3 | SCSS color file | `designer-scss-colors.png` | `_colors.scss` open with `$qs_*` variables |
| 4 | Style Designer with [Prototype] | `designer-style-designer.png` | Style Designer showing inheritance hierarchy |
| 5 | Target menu | `designer-target-menu.png` | Active Target dropdown showing Web Help and PDF |
| Done | Output or workflow | `designer-output-result.png` | Reverb output showing branded, customized result |

**Total: 7 placeholder screenshots** (1-2 per step + 1 in Done)

## Technical Considerations

### Content Architecture

**Intro rewrite:** The intro line below `# Quick Start` positions ePublisher as a multi-authoring platform. Specific format names (DITA, FrameMaker, Word) go in the intro — this is acceptable because the intro is a positioning statement, not a procedural step. The template guideline about avoiding format references applies to core step procedures, not the introductory framing.

**Step 1 — Document Manager interaction:** The Designer trial project has all 8 documents pre-loaded (unlike Express, where the user drags files in). Step 1 orients the user to observe the Document Manager with pre-loaded content, then proceeds to Generate All → view output in browser. This is a brief orientation step, not a hands-on Document Manager action.

**Step 1 — Which target first:** Web Help (WebWorks Reverb 2.0), consistent with the Express trial pattern. The user generates Web Help and views it in a browser before any customization.

**Step 1 — Returning user callout:** Include a blockquote at the top of Step 1:
```markdown
> **Returning user?** Choose **File > Open** and navigate to:
> `Documents\ePublisher Designer Projects\ePublisher Designer Trial\ePublisher Designer Trial.wep`
```
*(Path needs verification against actual installation.)*

**Step 4 — Style Designer procedure:** The user opens the Style Designer (via **View > Style Designer** or equivalent menu path), selects `[Prototype]`, changes a visible property (e.g., font family or font size), regenerates, and observes the cascading effect across all styles that inherit from [Prototype]. This makes the inheritance concept concrete through a hands-on action. *(Menu path needs verification against actual Designer UI.)*

**Done section:** Use an output screenshot showing the branded, customized Reverb output — this validates the user's work ("you did it") which is more immediately rewarding than a conceptual workflow diagram. The Stationery architecture is already covered in Explore More.

**Express reference:** Removed entirely from the intro. Express appears only in the Product Family comparison table in Explore More. No "skip to Step 2" signal for Express graduates — Step 1 is kept short enough (8-10 procedural lines) that everyone reads it.

### Explore More Additions

**Feature exploration table:** Modeled on the Express guide's "Try These Features" table (Express lines 82-90). Focus on output features the user can verify in their generated Web Help: search, responsive layout, share widget, click-to-zoom images, PDF format switching. These are the same Reverb 2.0 features regardless of whether Designer or Express generated them.

**AutoMap section:** Modeled on Express guide (Express lines 127-139). Covers CI/CD automation, scheduled publishing, AI agent access, headless operation. References "Landmark IDs and Knowledge Base from your Reverb output" (generated in Step 1). Includes download link.

### Line Budget

| Section | Current | Target | Notes |
|---------|---------|--------|-------|
| Core steps (Steps 1-5 + Done) | ~67 lines | ~75 lines | 5 steps + screenshots need room |
| Explore More | ~62 lines | ~95 lines | Adding feature table + AutoMap |
| **Total** | **~132 lines** | **~170-180 lines** | Within expanded budget |

### Template Update

The trial guide template (`.claude/instructions/trial-guide-template.md`) needs updating:
- Step count: "2 steps" → "2-5 steps depending on product"
- Core step budget: "Under 45 lines" → "Under 45 lines (Express), under 75 lines (Designer)"
- Screenshot max: "Maximum: 2 screenshots" → "1-2 per step, as needed for visual confirmation"
- Total budget: "120-150 lines" → "120-180 lines depending on step count"
- Product customization table: Update Designer row for 5 steps

## Acceptance Criteria

### Content Changes (`designer-trial-guide.md`)

- [x] **Intro rewritten:** Multi-authoring positioning mentions DITA, FrameMaker, Word; explains Markdown is the trial format for transparency; no Express reference
- [x] **Step 1 added:** "Open & Generate" covers project auto-open, Document Manager orientation, Generate All, viewing output in browser. Includes returning user callout
- [x] **Step 2 (was Step 1):** Content Rules step renumbered, content preserved (fix any text errors)
- [x] **Step 3 (was Step 2):** Brand Output step renumbered, content preserved (fix any text errors)
- [x] **Step 4 added:** Style Designer step with hands-on procedure — open Style Designer, observe [Prototype] inheritance, change a property, regenerate to see cascade
- [x] **Step 5 (was Step 3):** Multiple Targets step renumbered, content preserved (fix any text errors)
- [x] **Done section redesigned:** Output screenshot placeholder replaces generic congratulations; inspiring CTA
- [x] **Explore More: Feature table added** showing output features (search, responsive, share, zoom, PDF)
- [x] **Explore More: AutoMap section added** with CI/CD, AI agent, Landmark ID references
- [x] **Screenshots:** 6 placeholder image references using `designer-` prefix and `<!-- style:Screenshot -->` syntax (Step 1 combined into single screenshot)
- [x] **Aliases:** All new headings have semantic aliases (`<!-- #open-generate -->`, `<!-- #style-designer -->`, etc.)
- [x] **Text errors fixed:** View Differences description corrected; intro sentences tightened
- [x] **Total line count:** 185 lines (slightly over 180 target due to 5 steps + 6 screenshots)

### Template Update (`.claude/instructions/trial-guide-template.md`)

- [x] Updated step count guidance for Designer (5 steps)
- [x] Updated line budgets (core: 75, total: 180 for Designer)
- [x] Updated screenshot guidance (per-step, not fixed max)
- [x] Updated product customization table

### CLAUDE.md Update

- [x] Update project structure tree if needed
- [x] Update "Design Principles" section with revised line budgets
- [x] Update "Scalability" section to reflect that guides may have different step counts

## Implementation Phases

### Phase 1: Template & CLAUDE.md Updates

Update the supporting documentation first so the guide rewrite has the correct constraints to follow.

**Files:**
- `.claude/instructions/trial-guide-template.md` — Update step count, line budgets, screenshot guidance
- `CLAUDE.md` — Update design principles and structure notes

### Phase 2: Guide Rewrite

Rewrite `latest/online-trial-guides/designer-trial/designer-trial-guide.md` in a single pass:

1. Rewrite header markers and intro
2. Add Step 1: Open & Generate (new content)
3. Renumber and revise Step 2: Content Rules (existing content, fix errors)
4. Renumber and revise Step 3: Brand Output (existing content, fix errors)
5. Add Step 4: Style Designer (new content)
6. Renumber and revise Step 5: Multiple Targets (existing content, fix errors)
7. Rewrite Done section
8. Add feature exploration table to Explore More
9. Add AutoMap section to Explore More
10. Update "What You Just Did" in Explore More to reflect 5-step structure
11. Verify all aliases, screenshot syntax, and Markdown++ patterns

### Phase 3: Verification

- [x] All aliases are unique and semantic (14 unique aliases)
- [x] All screenshot placeholders use correct `<!-- style:Screenshot -->` syntax (6 instances)
- [x] No Express references in intro; architectural references in Explore More are appropriate
- [x] Line count within budget (185 lines)
- [x] All existing Explore More sections preserved (Stationery, Multiple Targets Detail, AI Skills, Product Family) plus new Try These Features and AutoMap

## Dependencies & Risks

**Dependencies:**
- Screenshot PNGs must be captured separately after the guide text is finalized (out of scope for this implementation)
- Designer trial project file path must be verified for the returning user callout
- Style Designer menu path must be verified for Step 4 instructions

**Risks:**
- **75-line core budget is tight** with 5 steps + 7 screenshots. Each screenshot reference uses 2-3 lines (style comment + image + alt text). May need to compress existing step text.
- **Step 4 procedure depends on actual Designer UI** — the specific property change that best demonstrates [Prototype] inheritance needs hands-on validation in the product.

## Sources & References

### Origin

- **Brainstorm document:** [docs/brainstorms/2026-03-03-designer-trial-standalone-brainstorm.md](docs/brainstorms/2026-03-03-designer-trial-standalone-brainstorm.md) — Key decisions: 5-step hybrid structure, multi-authoring intro, Style Designer step with prototype inheritance, screenshots throughout, Express reference only in Product Family table

### Internal References

- Current Designer guide: `latest/online-trial-guides/designer-trial/designer-trial-guide.md` (132 lines)
- Express guide (pattern reference): `latest/online-trial-guides/express-trial/express-trial-guide.md` (140 lines)
- Trial guide template: `.claude/instructions/trial-guide-template.md`
- Documentation patterns: `.claude/instructions/documentation-patterns.md`
- Designer project file: `latest/local-trial-projects/ePublisher Designer Trial/ePublisher Designer Trial.wep`

### External References

- Full ePublisher documentation: https://static.webworks.com/docs/epublisher/latest/help/
- Markdown++ syntax: https://static.webworks.com/docs/epublisher/latest/help/Authoring%20Source%20Documents/_markdown.1.01.html
