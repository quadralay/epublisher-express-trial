<!-- markers:{"Keywords": "designer, trial, getting started, customization, branding, stationery", "Description": "First-time user introduction to ePublisher Designer customization"}; #quick-start -->
# Quick Start

Customize branding, content rules, and output formats for professional documentation.

If you completed the Express trial, you already know how to generate — now you'll customize what Express produces. New to ePublisher? This guide is self-contained.

<!-- #content-rules -->
## Step 1: Customize Content Rules

Variables and conditions let you personalize and filter content without editing source documents.

**Change the product name everywhere at once:**

1. Select the **Web Help** target in the Target menu
2. Open **Target** > **Target Settings**
3. Find the **Variables** section — change `ProductName` from "Quantum Sync" to your product name
4. Click **Generate All** — every page now displays your product name

**Control what content appears:**

1. In the same Target Settings, find the **Conditions** section
2. Change `advanced` from **Visible** to **Hidden**
3. Click **Generate All** — administrator settings and deployment details disappear

> **Tip:** One project, different outputs per audience. Toggle conditions per target to publish beginner and advanced guides from the same source documents.

<!-- #brand-output -->
## Step 2: Brand the Output

Make the output yours with custom colors and a branded PDF cover.

**Change the color theme:**

1. Click **Format** > **View Differences** to see default styles (left) versus your overrides (right)
2. Open `Formats/WebWorks Reverb 2.0/Pages/sass/_colors.scss`
3. Find `$qs_primary_brand_color: #0a4d8c` — change `#0a4d8c` to your brand color
4. Optionally change `$qs_secondary_brand_color` and `$qs_content_background_color`
5. Click **Generate All** — the entire web theme transforms

> **VS Code users:** Open `_colors.scss` in VS Code for a built-in color picker.

**Replace the PDF cover:**

1. Click **View** > **Project Directory** and open `Files`
2. Replace `pdf-cover.png` with your own cover image (keep the same filename)
3. Switch **Active Target** to **PDF** and click **Generate All** — your cover appears on page one

<!-- #multiple-targets -->
## Step 3: Generate Multiple Targets

Your project includes two configured targets: **Web Help** and **PDF**.

1. Switch **Active Target** to **Web Help** → click **Generate All** → view the branded web output
2. Switch **Active Target** to **PDF** → click **Generate All** → view the print-ready PDF
3. Conditions are configured per target: `online_only` content appears in Web Help, `print_only` content appears in PDF

Same source documents, same style rules — two completely different output formats.

<!-- #done -->
## Done

You've branded a professional documentation site, controlled content per audience, and published to multiple formats — all from one set of source documents.

**Next:** Save your design as reusable Stationery and distribute it to Express users, or keep reading to understand the architecture.

[Full documentation](https://static.webworks.com/docs/epublisher/latest/help/) | [Contact sales](mailto:sales@webworks.com)

---

<!-- #explore-more -->
## Explore More

You customized a complete publishing project. Here's how the pieces connect.

<!-- #what-you-just-did -->
### What You Just Did

The three steps map to Designer's three control layers:

1. **Content rules** (Step 1) — Variables and conditions control what content appears and how it's personalized, per target
2. **Visual theme** (Step 2) — SCSS stylesheets and branding assets control the look and feel
3. **Output targets** (Step 3) — Format configurations control the delivery medium

ePublisher separates *design* from *production*. Designer is where you create publishing standards. Express is where authors publish day-to-day against those standards — without needing Designer installed. The bridge between them is Stationery.

> **Beyond Markdown:** ePublisher also processes Adobe FrameMaker, Microsoft Word, and DITA-XML source documents using the same Designer workflow.

<!-- #stationery -->
### Create & Distribute Stationery

Stationery is the architectural core of ePublisher:

- Save your customized project as a Stationery template (`.wxsp` file)
- Distribute the Stationery to Express users across your organization
- Authors publish with your brand, rules, and targets — without needing Designer
- Update the Stationery once when standards change → all Express projects pick up the changes

One Designer user controls publishing standards. Many Express users publish against them.

<!-- #multiple-targets-detail -->
### Multiple Targets, One Source

Targets are not limited to different formats. The most common use is multiple targets of the *same* format with different configurations — different conditions for different product versions, different branding for different customers, or different variable values for different editions. Create a new target, adjust its settings, and publish a distinct output without duplicating source documents.

Designer also supports additional output formats beyond Web Help and PDF: EPUB, Eclipse Help, HTML Help, and more.

<!-- #ai-skills -->
### AI-Assisted Theme Design

A complete set of [AI skills for Claude Code](https://github.com/quadralay/webworks-claude-skills) is publicly available for ePublisher:

- Design color themes and generate SCSS palettes
- Configure style rules and content mappings
- Author and validate Markdown++ source documents
- Automate repetitive publishing tasks

Designer is AI-augmented — AI skills accelerate design work that would otherwise require manual SCSS editing and trial-and-error iteration.

<!-- #product-family -->
### The ePublisher Product Family

| | **Express** | **Designer** | **AutoMap** |
|---|---|---|---|
| **Who it's for** | Authors publishing content | Teams controlling brand and design | DevOps automating builds |
| **What it does** | Generate output from Stationery | Create and customize Stationery | CLI and scheduled builds |
| **Source formats** | Markdown++, Word, FrameMaker, DITA | Same | Same |
| **Output formats** | Reverb 2.0, PDF, others | Same + full skin editing | Same |
| **Key capability** | One-click publish | Pixel-level design control | CI/CD and AI agent access |

[Download ePublisher Designer](https://webworks.com/products/epublisher/download) — includes Express for your authors.
