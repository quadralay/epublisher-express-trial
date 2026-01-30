# Trial Guide Template

This template defines the pattern for all ePublisher trial guides (Express, AutoMap, Designer).

## Structure

```markdown
<!-- markers:{"Keywords": "[product], trial, getting started", "Description": "[Product] quick start guide"}; #quick-start -->
# Quick Start

[1 sentence: outcome user will achieve]

<!-- #step-1 -->
## Step 1: [Product-Specific Action]

[Brief description of what this step accomplishes]

1. [First action]
2. [Second action]
3. [Third action]

![Descriptive alt text](images/[product]-[action].png)

> **Tip:** [One helpful hint relevant to this step]

<!-- #generate -->
## Step 2: Generate

1. Verify the **Active Target** shows **WebWorks Reverb 2.0**
2. Click **Generate All**
3. Wait ~30 seconds for processing
4. Click **Yes** to view your output

![Generate All button](images/[product]-generate-button.png)

Your output opens automatically. Try these features:

<!-- multiline -->
| Feature        | What to Try                                    |
|----------------|------------------------------------------------|
| **Search**     | Type a few characters in the search box        |
|                |                                                |
| **Responsive** | Drag the browser edge to make it narrower      |
|                |                                                |
| **Share**      | Click the Share widget to copy a link          |
|                |                                                |
| **PDF**        | Change target to **PDF-XSL-FO** and regenerate |
|                |                                                |

<!-- #done -->
## Done

[1 sentence celebration of accomplishment]

**Next:** [Single CTA to next product tier or customization]

[Full documentation](https://static.webworks.com/docs/epublisher/latest/help/) | [Contact sales](mailto:sales@webworks.com)
```

## Guidelines

### Length
- Target: 60-80 lines maximum
- Reading time: Under 2 minutes

### Screenshots
- Maximum: 2 screenshots per guide
- Naming: `[product]-[descriptive-name].png`
- Only include where UI is not self-explanatory

### Markdown++ Features
Use lightly to keep source simple:
- **Aliases:** Required on all significant headings
- **Markers:** Keywords and Description in header
- **Multiline tables:** For feature exploration
- **Content islands:** One tip callout maximum
- **Conditions:** Optional, for audience-specific content

### What to Avoid
- Welcome/value proposition sections
- Multiple "Next Steps" options
- Feature explanations (link to full docs)
- Legacy format references (Word, FrameMaker, DITA)
- More than 2 screenshots

## Product-Specific Customization

| Product | Step 1 Action | Step 1 Screenshot |
|---------|---------------|-------------------|
| Express | Add Markdown++ documents | Document Manager drag target |
| AutoMap | Select source files/folders | Source selection dialog |
| Designer | Customize stationery styles | Style Designer panel |

## Directory Structure

```
[product]-trial/
├── [product]-trial-guide.md
└── images/
    ├── [product]-[step1-action].png
    └── [product]-generate-button.png
```
