# Changelog

All notable changes to this repository are documented in this file.

The format follows Keep a Changelog and semantic versioning.

## [Unreleased] - 2026-02-14

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
