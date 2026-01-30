---
title: Phase 2 Express Trial Guide Enhancements
type: docs
date: 2026-01-30
---

# Phase 2 Express Trial Guide Enhancements

Enhance the Express trial guide with better feature teasing, stronger CTAs, and an optional "Explore More" section.

## Acceptance Criteria

### 1. Source Document Types Note
- [x] Add note after Step 1 tip mentioning Word, FrameMaker, and DITA support
- [x] Keep Markdown++ as primary focus

### 2. Generation Feedback Update
- [x] Replace "Wait ~30 seconds for processing" with description of log generation and popup completion
- [x] Describe what user sees: log activity, then popup asking to view output

### 3. Stronger CTA
- [x] Change "Open ePublisher Designer" to "Download Designer" with link
- [x] Use action-oriented language: "Download Designer to unlock full customization"
- [x] Replace placeholder `[DESIGNER_URL]` with actual URL before publishing

### 4. Softer Writing Tone
- [x] Expand terse phrases to friendlier sentences
- [x] Keep concise but not aggressive

### 5. Value-Focused Feature Table
- [x] Change column header from "What to Try" to "What You Get"
- [x] Transform action descriptions to benefit statements:
  - Search: "Instant answers with breadcrumb context"
  - Responsive: "Perfect reading on any device"
  - Share: "Direct links to any page"
  - Images: "Click-to-zoom for details"
  - PDF: "One-click format switching"

### 6. Explore More Section (Optional)
- [x] Add horizontal rule separator after Done links
- [x] Add `## Explore More (Optional)` heading with alias
- [x] Include Target Settings subsection:
  - Access via menu path (Target > Settings or similar)
  - Table showing Header, Footer, Tabs settings
- [x] Include Designer pitch with `[DESIGNER_URL]` placeholder
- [x] Include AutoMap pitch with `[AUTOMAP_URL]` placeholder (equal billing)
- [x] No screenshots in this section

### 7. Template Update
- [x] Update `TRIAL-GUIDE-TEMPLATE.md` line limit from 60-80 to ~100 lines
- [x] Add optional "Explore More" section pattern

## Context

**Files to modify:**
- `express-trial/express-trial-guide.md`
- `TRIAL-GUIDE-TEMPLATE.md`

**Brainstorm reference:** `docs/brainstorms/2026-01-30-feature-teasing-explore-more-brainstorm.md`

**Key decisions from brainstorm:**
- Value-focused tone (benefits not actions)
- Integrated Enhancement approach (single file, ~100 lines)
- Strong pitch style for CTAs
- Designer and AutoMap get equal billing
- No screenshots in Explore More

**Placeholders to replace before publishing:**
- `[DESIGNER_URL]` - Designer download/trial page
- `[AUTOMAP_URL]` - AutoMap download/trial page

## References

- Phase 2 prompt: `docs/prompts/2026-01-30-phase-2.md`
- Current guide: `express-trial/express-trial-guide.md`
- Legacy guide (tone reference): `legacy/express-trial-guide.md`
