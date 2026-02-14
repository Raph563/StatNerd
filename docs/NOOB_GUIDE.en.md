# Beginner Guide (EN)

This guide uses generic paths only (no personal machine path).

## 1) Prepare the repo

```powershell
cd C:\path\to\repo
git status
```

## 2) Automatic alpha release

You no longer need to run the alpha command manually:

- commit your changes,
- push to `main`,
- workflow auto-creates `vX.Y.Z-alpha.N` and publishes the release.

Manual alpha command (optional):

```powershell
.\scripts\release.ps1 -Version 1.2.1
```

## 3) Create a beta release

```powershell
.\scripts\release.ps1 -Version 1.2.1 -Channel beta
```

## 4) Create a stable release

```powershell
.\scripts\release.ps1 -Version 1.2.1 -Channel stable
```

## 5) Verify on GitHub

1. Open `Actions` in the repository.
2. Open workflows `Auto Alpha Release` then `Release`.
3. Confirm `publish` job is green.
4. Open `Releases` and confirm:
   - release tag,
   - ZIP asset.

## 6) Common errors

- `Working tree is not clean`: commit or stash changes.
- `Tag already exists`: pick a new version or channel.
- GitHub Actions failure: check repo permissions/actions/billing.

## Links

- EN release guide: `RELEASING.en.md`
- EN overview: `README.en.md`
- FR version: `NOOB_GUIDE.fr.md`
