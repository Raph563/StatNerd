# Changelog

## [4.0.0] - 2026-02-19

### Breaking
- Repository moved to `Raph563/StatNerd`.
- StatNerd now requires NerdCore at runtime (`window.NerdCore`).
- Install/update scripts now require `config/data/custom_js_nerdcore.html`.

### Added
- Runtime registration to NerdCore addon registry.
- Settings access delegation to NerdCore settings page (`/stocksettings?nerdcore=1`).

### Changed
- Compose order defaults now include NerdCore first:
  - `custom_js_nerdcore.html`
  - `custom_js_nerdstats.html`
  - `custom_js_product_helper.html`
- Release asset renamed to `statnerd-addon-vX.Y.Z.zip`.
