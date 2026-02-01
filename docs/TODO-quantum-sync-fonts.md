# TODO: Configure Quantum Sync Fonts in ePublisher Designer

## Overview

The Quantum Sync branding includes a professional font pairing that needs to be configured in ePublisher Designer for the documentation content. The logo assets already use these fonts, but the generated HTML/PDF output needs font configuration.

## Recommended Fonts

| Use Case | Font | Weight | Download |
|----------|------|--------|----------|
| **Headlines/UI** | Space Grotesk | 500-700 | [Google Fonts](https://fonts.google.com/specimen/Space+Grotesk) |
| **Body Text** | Inter | 400-600 | [Google Fonts](https://fonts.google.com/specimen/Inter) |
| **Code/Monospace** | Space Mono | 400-700 | [Google Fonts](https://fonts.google.com/specimen/Space+Mono) |

### Why These Fonts?

- **Space Grotesk**: Futuristic geometric sans-serif, perfect for "Quantum" tech branding
- **Inter**: Industry standard for screen readability (used by GitHub, Mozilla)
- **Space Mono**: Consistent geometric family for code blocks
- All are Google Fonts: free, open source, commercially usable
- All work well for both web AND print (PDF) output

## Configuration Steps

### Option 1: Web Fonts (Recommended for Online Help)

Add to `_override-skin.scss`:

```scss
// Google Fonts import
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Space+Grotesk:wght@500;600;700&family=Space+Mono:wght@400;700&display=swap');

// Override main font variables
$font_family_main: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
$toolbar_font: 'Space Grotesk', sans-serif;
$toolbar_logo_font: 'Space Grotesk', sans-serif;
$menu_font: 'Inter', sans-serif;
$menu_toc_font: 'Inter', sans-serif;
$menu_toc_title_font: 'Space Grotesk', sans-serif;
```

### Option 2: Local Fonts (Required for PDF/Print)

1. Download font files from Google Fonts
2. Install fonts on the system running ePublisher Designer
3. Reference fonts by name in the project styles

### Key Font Variables in Reverb 2.0

| Variable | Purpose | Recommended Value |
|----------|---------|-------------------|
| `$font_family_main` | Body text throughout | Inter |
| `$toolbar_font` | Toolbar UI elements | Space Grotesk |
| `$toolbar_logo_font` | Logo text (if text-based) | Space Grotesk |
| `$menu_font` | Navigation menu | Inter |
| `$menu_toc_font` | Table of contents | Inter |
| `$menu_toc_title_font` | TOC section headers | Space Grotesk |

## File Location

Configuration file:
```
latest/local-express-trial-project/ePublisher Designer Trial/
  Formats/WebWorks Reverb 2.0/Pages/sass/_override-skin.scss
```

## Related Files

- Color scheme: `_colors.scss` (already updated)
- Logo assets: `Files/` directory (already updated)
- Plan: `docs/plans/2026-02-01-feat-quantum-sync-branding-plan.md`

## Status

- [x] Logo assets created with Space Grotesk wordmark
- [x] Color scheme configured
- [ ] Font variables configured in `_override-skin.scss`
- [ ] PDF font embedding verified
- [ ] Regenerate output to test fonts
