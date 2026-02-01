---
date: 2026-02-01
topic: quantum-sync-branding
---

# Quantum Sync Branding: Color Scheme and Logos

## What We're Building

A complete visual identity for the fictitious **Quantum Sync** company, a Tech/SaaS software company. This includes:

1. **Color scheme** updates to `_colors.scss`
2. **Five logo assets** for the ePublisher Designer trial project:
   - `favicon.png` (small icon, typically 32x32 or 16x16)
   - `footer-logo.png` (wider format for site footer)
   - `og.png` (1200x630 for Open Graph social sharing)
   - `pdf-cover.png` (full page cover with company branding)
   - `toolbar-logo.svg` (header navigation logo)

**Target:** Professional, enterprise-grade SaaS aesthetic.

## Why This Approach

### Color Direction: Professional Blue Gradient

Chose **Approach A** (deep blue-to-teal gradient) because:
- Industry standard for enterprise SaaS—instantly establishes trust
- High contrast ensures excellent readability
- Teal accent adds modern "sync/connectivity" energy without being unconventional

Rejected alternatives:
- Electric Teal: More distinctive but less corporate-traditional
- Navy + Gold: Premium feel but reads "fintech" rather than general SaaS

### Logo Direction: Abstract Symbol + Wordmark

- Geometric icon representing "quantum" (orbital/electron motif) or "sync" (arrows/rotation)
- Clean sans-serif wordmark "Quantum Sync"
- Works at multiple sizes (favicon to PDF cover)

### Creation Method: AI Image Generation

Using Gemini imagegen skill for custom logo creation:
- Generates unique, professional-quality assets
- Can iterate on prompts to refine
- Free to use and distribute (no licensing concerns)

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Company Type | Tech/SaaS | Modern, relatable for trial users |
| Primary Color | `#0a4d8c` (deep blue) | Professional, trustworthy |
| Accent Color | `#00b8d4` (bright cyan) | Modern, "sync" associations |
| Dark Color | `#1a1a2e` | High contrast for text |
| Light/Background | `#f4f7fa` | Cool off-white, easy on eyes |
| Logo Style | Symbol + Wordmark | Versatile across all asset sizes |
| Creation Method | Gemini AI imagegen | Custom, free-to-use assets |

## Color Palette Specification

```scss
// Quantum Sync Brand Colors
$primary_brand_color: #0a4d8c;      // Deep professional blue
$primary_text_color: #1a1a2e;       // Near-black for readability
$skin_background_color: #ffffff;    // Clean white toolbar
$secondary_brand_color: #e8f4f8;    // Cool light blue-gray
$secondary_text_color: #ffffff;     // White text on dark backgrounds
$tertiary_brand_color: #00b8d4;     // Bright cyan accent
$content_background_color: #f4f7fa; // Cool off-white page background
```

## Logo Asset Requirements

| Asset | Dimensions | Purpose | Key Elements |
|-------|------------|---------|--------------|
| favicon.png | 32x32 or 48x48 | Browser tab icon | Symbol only, high contrast |
| toolbar-logo.svg | ~200x40 | Header navigation | Symbol + "Quantum Sync" text |
| footer-logo.png | ~180x50 | Site footer | Symbol + wordmark, lighter variant |
| og.png | 1200x630 | Social sharing | Full branding, tagline space |
| pdf-cover.png | ~800x1000+ | PDF cover page | Full company branding, background imagery |

## Open Questions

- **Tagline:** Should Quantum Sync have a tagline for the og.png/pdf-cover? (e.g., "Sync Smarter. Scale Faster.")
- **Symbol specifics:** Orbital rings? Interlocking Q-shapes? Sync arrows? (Will explore during generation)

## Next Steps

→ `/workflows:plan` to define implementation steps for generating and integrating assets
