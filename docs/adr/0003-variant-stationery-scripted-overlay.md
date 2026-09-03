# The variant Stationery is a scripted chrome overlay on Quantum Sync Stationery, not a second Designer project

The AutoMap trial's re-skin step needs a second evaluation Stationery that differs from Quantum Sync Stationery in chrome only (ADR-0002; the re-skin mechanics in `docs/research/automap-trial-features.md`). The obvious way to author it — a second Designer project saved as Stationery — turns "identical style mappings" into a discipline instead of a guarantee: every rule edit in the Designer Trial would have to be repeated in a second project, and nothing would catch the drift, because a composition job does no design-mismatch detection. We decided the variant, **Quantum Sync Midnight Stationery**, owns only its chrome — the toolbar logo, footer logo and favicon under `Files/`, and the partials under `Formats/WebWorks Reverb 2.0/Pages/sass/` — tracked in git as its design source, and `scripts/sync_variant_stationery.py` derives everything else (the `.wxsp`, the format snapshots, the Settings, the rest of `Files/` such as the PDF cover, the manifest) from Quantum Sync Stationery.

## Considered Options

- A second Designer project saved as Stationery (mirrors how the base is made, but the style mappings would live twice, release migration would migrate two projects, and a stale copy would ship silently)
- Hand-copy the base Stationery folder and edit the chrome in place (a one-off: the gitignored files carry the design and nothing regenerates them after a release migration)

## Consequences

- Amends ADR-0002's consequence: release migration still saves the Stationery twice from the Designer Trial, but now touches three Stationery folders — the third by running the script, not Designer.
- The variant's `.wxsp` is byte-identical to the base's, so "identical style mappings" is verified by `diff`, and both Stationeries expose the same target names and IDs — a seeded job can be repointed between them without a target mismatch.
- Release migration regenerates the variant with one command after the base is re-saved (`docs/agents/release-migration.md` § 2); `--check` fails when the variant has drifted from the base.
- Chrome changes are made in the variant's tracked SCSS partials and logo files with a text editor, never in Designer; Designer is not needed to maintain the variant.
- The variant is the only Stationery under `Evaluation/` with tracked chrome files, so `.gitignore` carries negations for exactly those paths.
- The name settles the working name: "Quantum Sync Midnight" describes the chrome (midnight-navy toolbar, sidebar and page frame with a cyan accent; the content card stays light so parcel content reads the same) and sits naturally next to "Quantum Sync Stationery" in the New Job wizard and the guide.
