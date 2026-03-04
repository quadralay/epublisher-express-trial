# Trial Guide Template

This template defines the pattern for all ePublisher trial guides (Express, AutoMap, Designer).

## Structure

```markdown
<!-- markers:{"Keywords": "[product], trial, getting started", "Description": "[Product] quick start guide"}; #quick-start -->
# Quick Start

[1 sentence: outcome user will achieve]

<!-- #step-1 -->
## Step 1: [Product-Specific Action]

[1-2 sentences: Why this matters — frame the business problem this step solves]

[Brief description of what this step accomplishes]

1. [First action]
2. [Second action]
3. [Third action]

![Descriptive alt text](images/[product]-[action].png)

> **Tip:** [One helpful hint relevant to this step]

<!-- #generate -->
## Step 2: Generate

[1-2 sentences: Why this matters — frame what generation achieves]

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

---

<!-- #explore-more -->
## Explore More

[1-line intro connecting activation to evaluation]

### What You Just Did

[Explain the 3-part ePublisher workflow: source documents, Stationery, target]
[Define Stationery in one sentence]
[Blockquote callout mentioning additional source formats]

### Try These Features

[Action-oriented table: verb + what to observe]

### Customize Output Behavior

[Brief intro to Target Settings and how to access them]

| Setting     | What It Controls                          |
|-------------|-------------------------------------------|
| **Header**  | [Description]                             |
| **Footer**  | [Description]                             |
| **Tabs**    | [Description]                             |

### The ePublisher Product Family

[Comparison table: Express vs Designer vs AutoMap across key dimensions]

### Take Full Control with Designer

[Capability list: brand identity, page layout, search behavior, output formats]
[Stationery creation-distribution workflow]
[Download link with install detail]

### Automate with AutoMap

[Capability list: CI/CD, scheduled publishing, AI agent access, headless operation]
[Connect to Landmark IDs + Knowledge Base from Step 2]
[Download link]
```

## Guidelines

### Length
- Core steps + Done: Under 45 lines (Express, 2 steps) or under 75 lines (Designer, 5 steps)
- Explore More: Up to 95 additional lines
- Total: 120-150 lines (Express) or 150-180 lines (Designer)
- Core reading time: Under 2 minutes (Express) or under 4 minutes (Designer)
- Full guide reading time: Under 5 minutes (Express) or under 8 minutes (Designer)

### Screenshots
- 1-2 per step, as needed for visual confirmation of menus, dialogs, and actions
- Naming: `[product]-[descriptive-name].png`
- Only include where UI is not self-explanatory or users might look in the wrong place
- Use `<!-- style:Screenshot -->` on the line immediately before the image markdown

### Markdown++ Features
Use lightly to keep source simple:
- **Aliases:** Required on all significant headings
- **Markers:** Keywords and Description in header
- **Multiline tables:** For feature exploration
- **Content islands:** One tip callout maximum
- **Conditions:** Optional, for audience-specific content

### Why Framing
Each step should open with 1-2 sentences that frame the business problem the step solves. This helps evaluators see themselves in the problem before the procedure shows the solution. Keep it concise — the "why" motivates, the procedure demonstrates.

### What to Avoid in Core Steps
- Welcome/value proposition sections
- Multiple "Next Steps" options
- Feature explanations (link to full docs)
- Legacy format references (Word, FrameMaker, DITA)
- More than 2 screenshots

### Allowed in Explore More
- Format references (Word, FrameMaker, DITA) in evaluation context
- Product comparisons and product ladder tables
- Stationery concept explanation
- Guided feature exploration with action-oriented tables
- Capability lists for Designer and AutoMap

## Product-Specific Customization

| Product | Steps | Core Step Structure |
|---------|-------|---------------------|
| Express | 2 | Step 1: Add Documents → Step 2: Generate |
| Designer | 5 | Step 1: Open & Generate → Step 2: Content Rules → Step 3: Brand Output → Step 4: Style Designer → Step 5: Multiple Targets |
| AutoMap | 2 | Step 1: Select source files → Step 2: Generate |

## Directory Structure

```
[product]-trial/
├── [product]-trial-guide.md
└── images/
    ├── [product]-[descriptive-name].png
    └── ...
```
