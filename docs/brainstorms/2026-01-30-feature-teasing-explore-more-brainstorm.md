---
topic: Feature Teasing and Explore More Section
date: 2026-01-30
status: complete
---

# Feature Teasing and Explore More Section

## What We're Building

Enhancements to the Express trial guide focused on two areas:

1. **Better Feature Teasing** - Transform the existing functional feature table into value-focused messaging that highlights what users gain, not just what to click.

2. **Optional "Explore More" Section** - A new section after the Done CTA that lets motivated users dig deeper into Target Settings, with strong equal-billing CTAs for Designer and AutoMap.

## Why This Approach

**Approach Chosen: Integrated Enhancement**

The guide will remain a single document with an extended line limit (~100 lines). This approach was selected because:

- User wanted "Feature showcase" depth for the Explore More section
- User preferred extending the line limit over splitting into multiple files
- Single document is easier to maintain
- Clear stopping point at "Done" - everything after is explicitly optional

**Rejected alternatives:**
- Progressive Disclosure (separate explore-more.md) - adds friction, two files to maintain
- Tiered CTAs (compact What's Next format) - not enough room to properly showcase Target Settings

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Feature teasing tone | Value-focused | Emphasize what users gain: "Search that finds answers instantly" vs "Type in search box" |
| Explore More depth | Feature showcase | Multiple subsections: Target Settings, Designer preview, AutoMap mention |
| Document length | Extend to ~100 lines | Allows full feature showcase without splitting files |
| Designer CTA style | Strong pitch | "Download Designer to unlock full customization" - action-oriented |
| AutoMap prominence | Equal billing | Both Designer and AutoMap presented as legitimate next paths |
| Screenshots in Explore More | None | Keep it text-only; users are exploring on their own at this point |

## Structure Outline

```markdown
## Step 2: Generate
[existing content]

Your output includes features your readers will love:  <-- NEW: benefit headline

| Feature | What You Get |  <-- CHANGED: "What You Get" vs "What to Try"
|---------|--------------|
| **Search** | Instant answers with breadcrumb context |  <-- value-focused
| **Responsive** | Perfect reading on any device |
| **Share** | Direct links to any page |
| **Images** | Click-to-zoom for details |
| **PDF** | One-click format switching |

## Done
[celebration line]

**Ready for more?** Download Designer to unlock full customization of colors, layouts, and branding.

[Download Designer](link) | [Full documentation](link) | [Contact sales](link)

---

## Explore More (Optional)

### Customize Output Behavior
[Introduce Target Settings, what they control]

| Setting | What It Controls |
|---------|-----------------|
| Header | Logo, navigation, search |
| Footer | Copyright, links |
| Tabs | Top navigation categories |

### Take Full Control with Designer
[Strong pitch for Designer download]

### Automate with AutoMap
[Equal-billing pitch for AutoMap]
```

## Open Questions

1. **Exact wording for value-focused feature descriptions** - Need to finalize the specific benefit language for each feature row

2. **Target Settings details** - Which specific settings are most compelling to highlight? Need to verify current UI labels match documentation

3. **Download URLs** - Confirm correct URLs for Designer and AutoMap downloads

4. **Template update** - TRIAL-GUIDE-TEMPLATE.md needs to be updated to reflect new 100-line limit and optional Explore More pattern

## Next Steps

Run `/workflows:plan` to create implementation plan for these changes.
