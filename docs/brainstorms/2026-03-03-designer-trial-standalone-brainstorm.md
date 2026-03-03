# Brainstorm: Make Designer Trial Guide Standalone

**Date:** 2026-03-03
**Status:** Complete

## What We're Building

Transform the Designer Trial Guide from a follow-on to the Express Trial Guide into the **primary entry point** for ePublisher evaluation users. The Designer trial provides a more complete picture of the custom publishing experience, so it should work for users who have never seen Express.

### Current State

- Designer guide assumes users know how to open a project, generate output, and use the Document Manager
- Single line on line 6 bridges Express users but claims "self-contained" — which it isn't in practice
- 3 core steps focus exclusively on customization (Content Rules, Brand Output, Multiple Targets)
- 0 screenshots; Express guide has 2
- No feature exploration table showing what the output contains
- No AutoMap section for CI/CD-minded evaluators

### Target State

- Designer guide works as a complete first-time experience
- Quick setup step establishes fundamentals before customization begins
- Screenshots throughout so users can visually confirm they're in the right place
- Style Designer step demonstrates the power of prototype-based style inheritance
- Intro positions ePublisher as a multi-authoring platform (DITA, FrameMaker, Word) with Markdown as the trial format
- Users understand what they built and what the output offers
- Product ladder (Designer -> AutoMap) visible to evaluators
- Express referenced only in the Product Family table, not in the intro
- "Done" section inspires rather than just congratulates — shows the output or the Stationery workflow

## Why This Approach

**Hybrid: Quick Setup Then Customize**

A brief "Open & Generate" step covers the fundamentals (opening the project, Document Manager, generation, viewing output) without diluting Designer's customization-focused identity. This approach:

- Gives first-time users enough context to understand what "Generate All" does
- Preserves the 3 customization steps as the core value proposition
- Avoids duplicating the Express guide's detailed hand-holding
- Keeps the guide focused on what makes Designer different: control

## Key Decisions

1. **Structure:** Hybrid — 5 core steps total:
   - Step 1: Open & Generate (establish baseline)
   - Step 2: Content Rules (conditions, variables)
   - Step 3: Brand Output (visual theming — see the result)
   - Step 4: Style Designer (explain the mechanics — prototype inheritance, parent styles)
   - Step 5: Multiple Targets
2. **Screenshots:** Multiple screenshots throughout — every step should have visual confirmation of menus, dialogs, and actions so users know exactly where to click. All assets use `designer-` prefix. Placeholder image references will be written into the guide; actual PNGs will be captured and added separately.
3. **Intro rewrite:** Strengthen multi-authoring positioning: ePublisher supports DITA, FrameMaker, and Word. This trial uses Markdown for transparency and ease of evaluation, but all concepts apply across authoring environments.
4. **Style Designer step:** New step showing the Style Designer interface. Explain that styles inherit from [Prototype], and parent relationships allow setting a property once to affect all or a subset of styles.
5. **Done section:** Replace bland congratulations with a screenshot of the output or a diagram of the ePublisher Stationery workflow — something that inspires and shows what they've accomplished.
6. **Explore More additions:** Feature exploration table + AutoMap section brought from Express pattern
7. **Express reference:** Remove from intro; keep only in the Product Family table in Explore More
8. **Line budget:** Up to 75 lines for core steps (5 steps + screenshots need room); total guide up to ~180 lines
9. **Errors in current text:** Will be addressed during implementation

## Scope

### In Scope

- Rewrite intro: multi-authoring positioning (DITA, FrameMaker, Word), explain Markdown trial choice
- Add Step 1: "Open & Generate" covering project launch, Document Manager, generation, output viewing
- Renumber existing steps to 2-4, add new Step 4: Style Designer
- Add Style Designer step: [Prototype] inheritance, parent style relationships, setting properties once
- Add screenshots throughout all steps showing menus, dialogs, and action locations
- Redesign "Done" section with output screenshot or Stationery workflow diagram
- Add feature exploration table to Explore More
- Add AutoMap section to Explore More
- Fix text errors encountered during rewrite
- Update trial guide template for revised line budget and step count

### Out of Scope

- Changes to the Express Trial Guide
- Changes to the sample Designer trial project files
- New Markdown++ source content
- AutoMap job file changes

## Open Questions

None — all key decisions resolved during brainstorming.
