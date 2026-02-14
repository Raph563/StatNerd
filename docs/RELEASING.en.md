# Release Publishing (EN)

## Prerequisites

- Clean git tree (`git status` with no changes).
- Push access to `origin`.

## Release channels

- `alpha` (automatic on each `main` push): `vX.Y.Z-alpha.N`
- `beta`: `vX.Y.Z-beta.N`
- `stable`: `vX.Y.Z`

## Prepare

1. Update `addon/VERSION` (example: `1.2.1`).
2. Update `addon/dist/custom_js.html`:
   - `const ADDON_RUNTIME_VERSION = '1.2.1';`
3. Update `CHANGELOG.md`.
4. Commit.

## Automatic alpha (default)

On each push to `main`, workflow `.github/workflows/auto-alpha-release.yml`:

- reads `addon/VERSION`,
- creates next `vX.Y.Z-alpha.N` tag,
- pushes the tag,
- then triggers `.github/workflows/release.yml` to publish the GitHub release.

## Manual release (beta/stable)

PowerShell:

```powershell
# beta
.\scripts\release.ps1 -Version 1.2.1 -Channel beta

# stable
.\scripts\release.ps1 -Version 1.2.1 -Channel stable
```

Shell:

```bash
# beta
./scripts/release.sh 1.2.1 --channel beta

# stable
./scripts/release.sh 1.2.1 --channel stable
```

## What scripts do

- Ensure clean working tree.
- Create annotated tag based on selected channel.
- Push branch and tag.

## GitHub publishing

Workflow `.github/workflows/release.yml` will:

- validate `addon/VERSION` against tag base version,
- build addon ZIP asset,
- publish GitHub release,
- auto-mark alpha/beta tags as prereleases.

## Links

- EN overview: `README.en.md`
- EN beginner guide: `NOOB_GUIDE.en.md`
- FR version: `RELEASING.fr.md`
