# StatNerd - Addon Pack (EN)

This directory contains the StatNerd distributable addon pack.

## Contents

- `dist/custom_js.html`: frontend payload.
- `scripts/install.*`: local install.
- `scripts/uninstall.*`: rollback.
- `scripts/export-from-local.*`: export from local instance.
- `scripts/update-from-github.*`: update from GitHub releases.
- `docker-sidecar/`: Docker sidecar option.

## Local install (generic)

Windows:

```powershell
cd addon\scripts
.\install.ps1 -GrocyConfigPath "C:\path\to\grocy\config"
```

Linux/macOS:

```bash
cd addon/scripts
./install.sh /path/to/grocy/config
```

## Links

- EN docs overview: `../docs/README.en.md`
- EN beginner guide: `../docs/NOOB_GUIDE.en.md`
- FR version: `README.fr.md`
