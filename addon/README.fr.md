# StatNerd - Pack Addon (FR)

Ce dossier contient le pack de distribution de StatNerd.

## Contenu

- `dist/custom_js.html`: payload frontend.
- `scripts/install.*`: installation locale.
- `scripts/uninstall.*`: rollback.
- `scripts/export-from-local.*`: export depuis instance locale.
- `scripts/update-from-github.*`: update depuis releases GitHub.
- `docker-sidecar/`: option sidecar Docker.

## Installation locale (générique)

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

## Liens

- Doc générale FR: `../docs/README.fr.md`
- Guide débutant FR: `../docs/NOOB_GUIDE.fr.md`
- Version EN: `README.en.md`
