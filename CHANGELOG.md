# Changelog

All notable changes to this repository are documented in this file.

The format follows Keep a Changelog and semantic versioning.

## [Unreleased] - 2026-02-14

- No entries yet.

## [1.2.1-alpha.13] - 2026-02-14

### Fixed
- Local focus panel no longer shows `Valeur` and `Prix moyen` rows when clicking chart elements.
- Sentinel expiry date `2999-12-31` is now treated as “no due date” across StatNerd data parsing and due-date classification.

### Added
- New settings option for expiry date display format in interface settings:
  - `Auto (langue UI)`
  - `YYYY-MM-DD`
  - `DD/MM/YYYY`
  - `MM/DD/YYYY`
- Local focus due date now includes relative remaining/overdue distance with adaptive units (days, weeks, months, years).

## [1.2.1-alpha.12] - 2026-02-14

### Added
- Desktop update relay app source (`desktop/relay`) for Windows/macOS:
  - local HTTP endpoint (`127.0.0.1:17863`)
  - executes existing update scripts automatically
  - one-click update flow from addon settings (no terminal command copy/paste)
- New update settings actions:
  - `Tester l’app desktop`
  - `Mettre à jour automatiquement`

### Changed
- Documentation links updated to include desktop relay app docs.
- Update settings now show dedicated relay status messages and disable controls while install is running.

## [1.2.1-alpha.11] - 2026-02-14

### Changed
- Local product cards (left list under group image) now use a minimal visual card style matching the group card: image-first card with a small product name at the bottom.
- Removed extra product meta text inside left cards so detailed information is shown only on the right info panel.
- Product thumbnails in local cards now use `contain` rendering for cleaner packaging/logo visibility.

## [1.2.1-alpha.10] - 2026-02-14

### Fixed
- Chart card action controls are now pinned to the top-right of each card header instead of sticking near the title.
- Removed conflicting Bootstrap `d-flex` header class injection that overrode the custom chart header grid alignment.

## [1.2.1-alpha.9] - 2026-02-14

### Added
- Local focus panel now supports product list unfolding from the left visual block for group-related focuses (group, brand, due/risk bucket): click the image block to unfold.
- Unfolded list shows top 5 products for the selected focus with clickable items that update right-side local details immediately.
- Added an `Afficher plus` action at the end of the unfolded list to switch to a scrollable full list.

### Changed
- Local focus layout reorganized to keep the visual/logo block on top-left and render the product list directly below it with slide animation.
- Right-side local stats now include a clearer group criterion summary before any product is selected.
- Group/brand local product list ordering now follows chart sort mode (highest-first or lowest-first).

## [1.2.1-alpha.8] - 2026-02-14

### Fixed
- Chart cards now keep strictly isolated settings per card (`Top/Tout`, tri, `0+`, type), including safer preference key normalization.
- Long labels are now truncated per chart card (compact and expanded views) to prevent overlap and unreadable axes.
- `Valeur par groupe` and `Calories par groupe` no longer inject an `Autres` bucket in `Top` mode, so each top item remains independently readable.
- Chart.js version detection now handles builds without `Chart.version`, avoiding inconsistent bar orientation/scales behavior.

### Changed
- Project naming introduced: **Donne Atlas**.
- Documentation restructured and split into FR/EN versions with cross-links.
- Removed machine-specific path examples from GitHub-facing docs.
- Release tooling now supports channels:
  - `alpha` (default)
  - `beta`
  - `stable`
- Release scripts now generate prerelease tags automatically for alpha/beta:
  - `vX.Y.Z-alpha.N`
  - `vX.Y.Z-beta.N`
- GitHub workflow release validation now compares `addon/VERSION` with the base tag version.
- GitHub workflow now marks alpha/beta tags as prereleases automatically.

### Fixed
- Barcode robots now auto-retry with simplified product names when standard lookup fails, without showing a separate retry button.
- Parent source checkbox persistence now writes only checked state (`1`) and no longer writes unchecked (`0`) automatically.
- Barcode robots now show a selected product info card (OFF/OPF source, product name, barcode, preview image, source link) before barcode creation.

## [1.2.0] - 2026-02-14

### Added
- Addon self-update section in settings:
  - GitHub release version check
  - update status (up-to-date / update available)
  - direct release link
  - copy-ready PowerShell and shell update commands
- New GitHub update scripts:
  - `addon/scripts/update-from-github.ps1`
  - `addon/scripts/update-from-github.sh`
- Beginner documentation:
  - `docs/NOOB_GUIDE.md`

### Changed
- Expanded root and addon README files with clearer install/update workflows.
- Release guide now includes runtime version constant sync (`ADDON_RUNTIME_VERSION`).

## [1.1.0] - 2026-02-14

### Added
- Root-level project documentation (`README.md`).
- Maintainer release guide (`RELEASING.md`).
- Automated GitHub Releases workflow (`.github/workflows/release.yml`).
- Cross-platform release helper scripts (`scripts/release.ps1`, `scripts/release.sh`).
- Addon version file (`addon/VERSION`).
- Config runtime policy documentation (`config/README.md`).

### Changed
- Repository scope clarified around distributable addon artifacts.
- `.gitignore` hardened for local runtime/sensitive Grocy data.

### Security
- Removed tracked runtime/local data from version control index:
  - database and caches
  - personal media and user files
  - logs and local cert keys
  - local runtime config file

## [1.0.0] - 2026-02-14

### Added
- Custom Grocy addon payload (`addon/dist/custom_js.html`).
- Guided addon compatibility setup and analytics features in frontend addon.
- Install/uninstall/export scripts for PowerShell and POSIX shell.
- Docker sidecar installer (`addon/docker-sidecar/*`).
- Addon documentation (`addon/README.md`).
