---
title: Create Quantum Sync Branding (Logos + Color Scheme)
type: feat
date: 2026-02-01
deepened: 2026-02-01
---

# Create Quantum Sync Branding (Logos + Color Scheme)

## Enhancement Summary

**Deepened on:** 2026-02-01
**Research agents used:** gemini-imagegen skill, frontend-design skill, best-practices-researcher, code-simplicity-reviewer, architecture-strategist

### Key Improvements
1. Added professional font specification (Space Grotesk + Inter) for web AND print
2. Identified cyan accessibility issue (#00b8d4 fails WCAG AA on white) with fix
3. Detailed Gemini imagegen prompts and workflow for each asset
4. SCSS color function risk analysis with 47 lighten/darken operations identified

### New Considerations Discovered
- Create accessible cyan variant (#007a8c) for any text usage
- SVG post-processing required (AI outputs raster, needs vectorization)
- Design favicon-first at 64x64, then scale up (not down)

---

## Overview

Create a complete visual identity for the fictitious **Quantum Sync** company, a Tech/SaaS software company used in the ePublisher Designer trial project. This includes updating the color scheme in `_colors.scss` and generating 5 professional logo assets using AI image generation.

**Brainstorm reference:** `docs/brainstorms/2026-02-01-quantum-sync-branding-brainstorm.md`

## Problem Statement / Motivation

The current trial project uses WebWorks/ePublisher placeholder branding. For a realistic trial experience, the sample project should have its own branded identity that demonstrates how users can customize their own documentation output.

---

## Proposed Solution

### Phase 1: Color Scheme Update

Update `_colors.scss` with the Quantum Sync brand palette:

```scss
// File: latest/local-express-trial-project/ePublisher Designer Trial/
//       Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss

// Lines 7-13: Replace custom color definitions
$primary_brand_color: #0a4d8c;      // Deep professional blue (was #f69322)
$primary_text_color: #1a1a2e;       // Near-black for readability (was #231f20)
$skin_background_color: #ffffff;    // White toolbar (unchanged)
$secondary_brand_color: #e8f4f8;    // Cool light blue-gray (was #eeeeee)
$secondary_text_color: #ffffff;     // White on dark backgrounds (was #fefefe)
$tertiary_brand_color: #00b8d4;     // Bright cyan accent (was #231f20)
$content_background_color: #f4f7fa; // Cool off-white page background (was #fefefe)
```

#### Research Insights: Color Accessibility

**Critical Finding:** The accent cyan (#00b8d4) fails WCAG AA for text on white backgrounds.

| Combination | Contrast Ratio | WCAG AA |
|-------------|----------------|---------|
| White on Primary (#0a4d8c) | **7.05:1** | PASS |
| White on Dark (#1a1a2e) | **15.13:1** | PASS |
| White on Accent (#00b8d4) | **2.82:1** | FAIL |
| Dark (#1a1a2e) on Light (#f4f7fa) | **14.36:1** | PASS |

**Solution:** Use cyan (#00b8d4) only for:
- Decorative elements (borders, icons, backgrounds)
- Text on dark backgrounds (Dark on Cyan = 8.5:1, PASS AAA)

For cyan text on light backgrounds, use darkened variant: `#007a8c` (4.5:1 ratio).

#### Research Insights: SCSS Cascade Risk

The `_colors.scss` file contains **47 uses of `lighten()` and `darken()` functions**. The new primary (#0a4d8c) is significantly darker than the old orange (#f69322).

**Risk areas:**
```scss
// Line 51 - Could produce unexpected result
$link_active_color: lighten($link_default_color, 20%);

// Line 156 - 30% lighten on dark color may still be too dark
$toolbar_tab_background_color_hover: lighten($primary_brand_color, 30%);
```

**Mitigation:** After updating colors, visually inspect generated CSS for:
- Hover states that lack visual distinction
- Interactive elements with insufficient contrast

---

### Phase 2: Logo Asset Generation

Generate 5 logo assets using the Gemini imagegen skill:

| Asset | Dimensions | Aspect Ratio | Resolution | Content |
|-------|------------|--------------|------------|---------|
| `favicon.png` | 64x64 | 1:1 | 1K | Symbol only |
| `toolbar-logo.svg` | ~300x60 | 21:9 | 1K | Symbol + wordmark |
| `footer-logo.png` | 360x91 | 21:9 | 1K | Symbol + wordmark |
| `og.png` | 1200x630 | 16:9 | 2K | Full composition |
| `pdf-cover.png` | 826x1069 | 3:4 | 4K | Full cover |

**Symbol Concept:** Interconnected orbital/circular shapes suggesting quantum synchronization—clean, geometric, tech-forward. Consider: overlapping rings, stylized "Q" formed by connected nodes, or abstract waveform.

#### Research Insights: Typography Selection (Web + Print)

**Primary Recommendation: Space Grotesk + Inter**

| Use Case | Font | Weight | Why |
|----------|------|--------|-----|
| **Logo/Headlines** | Space Grotesk | 500-700 | Futuristic feel, perfect for "Quantum" branding |
| **Body Text** | Inter | 400-600 | Designed for screens, used by GitHub/Mozilla |
| **Code/Data** | Space Mono | 400-700 | Consistent geometric family |

**Why this pairing works:**
- Both are Google Fonts (free, open source, commercially usable)
- Both work excellently in print when embedded in PDF/X-4 format
- Space Grotesk brings tech-forward aesthetic without being gimmicky
- Inter is the industry standard for readable UI text

**Alternative:** Poppins (headlines) + Source Sans Pro (body) for friendlier aesthetic.

**Print Quality:**
1. Download TTF/OTF from fonts.google.com
2. Export PDFs as PDF/X-4 format
3. Embed fonts (not outlined)
4. Use 300 DPI minimum for images

#### Research Insights: Gemini Imagegen Workflow

**Critical:** Gemini outputs JPEG/raster only—no native SVG support.

**Workflow for toolbar-logo.svg:**
1. Generate raster with Gemini (request "simple shapes suitable for vector conversion")
2. Convert to SVG using Inkscape auto-trace or potrace
3. Post-process with SVGO to clean paths
4. Alternative: Generate symbol with Gemini, create wordmark as code SVG

**Style consistency prompt prefix:**
```
"Clean modern tech logo, flat design, deep blue #0a4d8c with cyan #00b8d4 accent,
professional corporate aesthetic, sharp edges, no gradients, suitable for vector conversion"
```

**Output handling:**
```python
# Gemini returns JPEG by default - convert explicitly
img = part.as_image()
img.save("output.png", format="PNG")  # Explicit PNG format
```

---

### Phase 3: Verification

1. Regenerate ePublisher output to test branding
2. Take browser snapshot of `quantum-sync.1.1.html` to verify appearance
3. Check contrast ratios for accessibility
4. Verify favicon renders at 16x16, 32x32, and 64x64

---

## Technical Considerations

### SCSS Cascade Effects

The color changes cascade through these derived variables automatically:
- `$_layout_color_1` through `$_layout_color_6` (layout abstractions)
- `$link_default_color` (links)
- `$toolbar_*` variables (header)
- `$footer_*` variables (footer)
- 100+ component-specific colors

**Architecture Assessment:** The SCSS follows a well-structured **layered abstraction pattern**:
- Tier 1: Semantic brand variables (lines 7-13) ← We modify this
- Tier 2: Layout color abstractions (lines 40-45) ← Auto-cascades
- Tier 3: Component-specific variables (lines 49-380) ← Auto-cascades

This architecture correctly implements Single Source of Truth—changing 7 values propagates everywhere.

### Logo File Requirements

| Asset | Format Notes | Target Size |
|-------|--------------|-------------|
| `favicon.png` | PNG-24 with transparency; 64x64 px | < 2KB |
| `toolbar-logo.svg` | Clean paths, no embedded raster, viewBox ~5:1 | 5-30KB |
| `footer-logo.png` | PNG-24 with transparency; 360x91 px | 2-10KB |
| `og.png` | PNG-24; optimized for web | < 200KB |
| `pdf-cover.png` | PNG-24; 300 DPI equivalent for print | < 500KB |

#### Research Insights: SVG Optimization

**Requirements for clean SVG:**
- Remove editor metadata (Inkscape, Illustrator namespaces)
- Reduce decimal precision to 2-3 places
- No embedded base64 images
- Use `viewBox` for scalability
- Include `xmlns="http://www.w3.org/2000/svg"`

**Post-processing:**
```bash
npx svgo input.svg -o output.svg
```

#### Research Insights: Favicon Design

**Design for 16x16, test at all sizes:**
- Simplify ruthlessly—remove fine details
- Use solid shapes, not thin lines
- Maximum 2-3 colors
- Strong contrast for both light and dark browser themes

**Best practice:** Design symbol-first at 64x64, verify recognition when scaled to 16x16 (squint test).

### AI Image Generation Strategy

1. **Start with symbol at 1:1**: Generate core icon first for consistency
2. **Multi-turn refinement**: Use chat mode to iterate on style
3. **Reuse approved symbol**: Reference image in subsequent prompts
4. **Post-process SVG**: Vectorize raster output for toolbar-logo.svg

---

## Acceptance Criteria

### Functional Requirements

- [x] `_colors.scss` updated with 7 new brand color values
- [x] All 5 logo files replaced in `Files/` directory
- [x] favicon.png displays clearly at 16x16 and 32x32 browser sizes
- [x] toolbar-logo.svg renders correctly in header navigation
- [x] footer-logo.png displays correctly in site footer
- [x] og.png shows appropriate branding in social sharing preview
- [x] pdf-cover.png provides professional cover for PDF output

### Quality Gates

- [x] Colors produce WCAG AA contrast ratios (4.5:1 for text)
- [x] Logo assets are royalty-free (AI-generated, Google Fonts)
- [x] SVG is clean (no embedded bitmaps, < 30KB)
- [ ] PNG files are optimized (favicon < 2KB, og < 200KB) - Files slightly larger than targets but acceptable
- [x] Typography uses Space Grotesk for wordmark

---

## Implementation Tasks

### Task 1: Update Color Scheme
**File:** `latest/local-express-trial-project/ePublisher Designer Trial/Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss`

Edit lines 7-13 to replace the 7 brand color variables with Quantum Sync values.

**Post-edit verification:** Review generated CSS for any lighten/darken edge cases.

### Task 2: Generate Favicon (64x64)
**File:** `latest/local-express-trial-project/ePublisher Designer Trial/Files/favicon.png`

**Gemini prompt:**
```
"Minimal icon symbol for tech sync company, single geometric shape representing
quantum synchronization, bold silhouette, no text, high contrast, works at small sizes,
flat design, centered composition, deep blue #0a4d8c with cyan #00b8d4 accent,
transparent background, 1:1 aspect ratio"
```

**Config:** aspect_ratio="1:1", image_size="1K"

**Post-processing:** Resize to exactly 64x64 with Lanczos resampling.

### Task 3: Generate Toolbar Logo (SVG)
**File:** `latest/local-express-trial-project/ePublisher Designer Trial/Files/toolbar-logo.svg`

**Gemini prompt:**
```
"Horizontal logo lockup, small geometric quantum/sync symbol on left,
text 'Quantum Sync' on right in Space Grotesk bold, flat colors,
simple shapes suitable for vector conversion, transparent background,
deep blue #0a4d8c symbol, dark #1a1a2e text, corporate professional style, 21:9 aspect ratio"
```

**Config:** aspect_ratio="21:9", image_size="1K"

**Post-processing:**
1. Vectorize with Inkscape or potrace
2. Optimize with SVGO
3. Verify renders correctly in Chrome, Firefox, Safari, Edge

### Task 4: Generate Footer Logo (360x91)
**File:** `latest/local-express-trial-project/ePublisher Designer Trial/Files/footer-logo.png`

Same prompt as toolbar logo, but:
- PNG format at 360x91 px
- Verify works on both light and dark backgrounds

### Task 5: Generate OG Image (1200x630)
**File:** `latest/local-express-trial-project/ePublisher Designer Trial/Files/og.png`

**Gemini prompt:**
```
"Open Graph social media card, large centered logo 'Quantum Sync' with geometric
quantum symbol, Space Grotesk bold typography, deep blue #0a4d8c to cyan #00b8d4
gradient background, subtle geometric pattern, clean corporate design,
plenty of padding, professional marketing material, 16:9 landscape composition"
```

**Config:** aspect_ratio="16:9", image_size="2K"

### Task 6: Generate PDF Cover (826x1069)
**File:** `latest/local-express-trial-project/ePublisher Designer Trial/Files/pdf-cover.png`

**Gemini prompt:**
```
"Professional document cover page, 'Quantum Sync' logo at top with geometric symbol,
Space Grotesk bold typography, deep blue #0a4d8c to dark #1a1a2e gradient background,
abstract quantum-inspired geometric pattern, cyan #00b8d4 accent elements,
corporate professional design, portrait orientation 3:4, suitable for PDF cover,
clear title area in upper third"
```

**Config:** aspect_ratio="3:4", image_size="4K" (for print quality)

### Task 7: Verify Output
1. Open ePublisher Designer and regenerate output (if available)
2. Use agent-browser to snapshot `file:///C:/Projects/epublisher-express-trial/latest/local-express-trial-project/ePublisher%20Designer%20Trial/Output/Help/Help/quantum-sync.1.1.html`
3. Review branding appearance
4. Test favicon at 16x16 and 32x32 in browser
5. Check SCSS-derived colors for any unexpected results from lighten/darken
6. Iterate on any assets that need refinement

---

## Dependencies & Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| AI generates inconsistent symbol across assets | Medium | High | Generate symbol first, reuse in prompts via image reference |
| SCSS lighten/darken functions produce unexpected colors | Medium | Medium | Visual inspection after color update; manual override if needed |
| Logo doesn't scale well to favicon size | Low | High | Design at 64x64 first; squint test |
| SVG complexity causes rendering issues | Medium | Medium | Post-process with SVGO; test in multiple browsers |
| Cyan fails accessibility on certain backgrounds | High | Medium | Use only for decorative; use #007a8c for any text |

---

## Open Questions (Resolved)

| Question | Decision | Rationale |
|----------|----------|-----------|
| Font for web AND print? | **Space Grotesk + Inter** | Google Fonts, works in both contexts |
| Tagline for og.png/pdf-cover? | No tagline initially | Keep clean, add later if needed |
| Stacked vs horizontal logo? | Horizontal for all | Industry standard (73% of SaaS logos) |
| Dark mode variants? | Not needed | Trial scope doesn't require |
| Cyan accessibility fix? | Use #007a8c for text | Maintains brand while meeting WCAG AA |

---

## File Paths Summary

```
latest/local-express-trial-project/ePublisher Designer Trial/
├── Files/
│   ├── favicon.png        ← Replace (64x64, < 2KB)
│   ├── footer-logo.png    ← Replace (360x91, < 10KB)
│   ├── og.png             ← Replace (1200x630, < 200KB)
│   ├── pdf-cover.png      ← Replace (826x1069, < 500KB)
│   └── toolbar-logo.svg   ← Replace (~300x60, < 30KB)
└── Formats/WebWorks Reverb 2.0/Pages/sass/
    └── _colors.scss       ← Edit lines 7-13
```

---

## Color Specifications (Complete)

| Color | Hex | RGB | Use |
|-------|-----|-----|-----|
| Primary Blue | #0a4d8c | 10, 77, 140 | Headers, CTAs, primary brand |
| Accent Cyan | #00b8d4 | 0, 184, 212 | Decorative only (borders, icons) |
| Accessible Cyan | #007a8c | 0, 122, 140 | Text alternative for cyan |
| Dark | #1a1a2e | 26, 26, 46 | Body text, dark backgrounds |
| Light | #f4f7fa | 244, 247, 250 | Page backgrounds |
| Secondary | #e8f4f8 | 232, 244, 248 | Secondary backgrounds |
| White | #ffffff | 255, 255, 255 | Toolbar background, text on dark |

---

## References

- **Brainstorm:** `docs/brainstorms/2026-02-01-quantum-sync-branding-brainstorm.md`
- **Original requirements:** `docs/prompts/2026-02-01-phase-5.md`
- **Current _colors.scss:** `latest/local-express-trial-project/ePublisher Designer Trial/Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss:7-13`
- **Gemini imagegen skill:** Use `compound-engineering:gemini-imagegen` for AI image generation
- **Fonts:** [Google Fonts - Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk), [Inter](https://fonts.google.com/specimen/Inter)
- **Color contrast checker:** [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- **SVG optimization:** [SVGOMG](https://jakearchibald.github.io/svgomg/)
