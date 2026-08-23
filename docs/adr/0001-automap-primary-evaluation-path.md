# AutoMap becomes the self-contained primary evaluation path

The Express trial has been the simple evaluation entry point, but as of 2026.1 Designer has all of Express's features and AutoMap Administrator offers a simple no-design UI that can fill Express's role — while being the product we most want to sell and the preferred everyday UI. We decided to make the AutoMap trial the primary simple evaluation path: the AutoMap installer carries its own evaluation materials (Stationery, source docs, seeded jobs) and seeds them on first launch, depending on neither the Express installer (which today carries the trial Stationery) nor the Designer installer (which carries the project that creates it). AutoMap 2026.1 is verified fully standalone — it ships the entire publishing engine — so this is mechanically clean.

## Consequences

- Funnel roles: AutoMap is the upsell target and preferred UI; Designer is the conversion CTA (you need it to create your own Stationery — the real adoption hurdle); Express remains a low-cost publish/deploy entry point for price-sensitive newcomers, and its trial ships unchanged.
- New dev work in `trunk`: AutoMap installer evaluation payload, first-launch `.wez` extraction in `AutomapApplication.OnInitializePreferences`, and trial-guide URL auto-open — mirroring the existing Express implementation (see `docs/research/automap-trial-features.md` for the exact template).
- Evaluation Contract IDs must be configured to include the AutoMap component (confirmed configurable).
