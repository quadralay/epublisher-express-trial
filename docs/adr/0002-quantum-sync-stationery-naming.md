# The AutoMap evaluation Stationery is content-branded: "Quantum Sync Stationery"

The AutoMap evaluation needs a Stationery in its own installer payload, and the existing asset is named "ePublisher Express Trial Stationery" — a product brand the evaluation strategy is moving away from (ADR-0001). We decided the AutoMap evaluation ships its own copy named **Quantum Sync Stationery**: the Stationery is the design of the content, not of any product, and the neutral name reads naturally in the New Job wizard and in screenshots.

## Considered Options

- Reuse "ePublisher Express Trial Stationery" as-is (zero rename work, idempotent with Express's seeding, but Express branding in the middle of the AutoMap experience)
- "ePublisher AutoMap Trial Stationery" (consistent with old naming, but the Stationery isn't AutoMap-specific and the name forecloses later sharing)

## Consequences

Release migration touches two Stationery folders until the Express/Designer evaluations converge on the neutral asset.
