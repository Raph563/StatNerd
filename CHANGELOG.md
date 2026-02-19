# Changelog

## [4.1.0] - 2026-02-19

### Added
- Native settings page rendering on `/stocksettings?statnerd=1` with Grocy page layout.
- Restored settings grouping to include stats/graph block (`dash_rankings_full_section`).
- Addon registration metadata for NerdCore menu routing (`settingsSection`, `settingsTitle`, `settingsIcon`).

### Changed
- Runtime version bump to `4.1.0`.
- Legacy relay URL now resolves from NerdCore VPS API base (`/__nerdcore_update`).
- Legacy settings redirect now targets `NERDCORE.openSettingsPage('statnerd')`.

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
