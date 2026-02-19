# StatNerd Core - Pack Addon (FR)

Ce pack contient la ligne core (stats + graphiques).

Les fonctions produit ont ete separees dans:
- https://github.com/Raph563/Grocy_Product_Helper

## Contenu

- `dist/custom_js.html`: payload core dashboard.
- `scripts/install.*`: installation locale.
- `scripts/uninstall.*`: rollback.
- `scripts/update-from-github.*`: update depuis releases GitHub.
- `docker-sidecar/`: option sidecar Docker.

## Fichiers geres

- payload core: `config/data/custom_js_nerdstats.html`
- payload product helper: `config/data/custom_js_product_helper.html` (si installe)
- fichier actif compose: `config/data/custom_js.html`
- etat core: `config/data/grocy-addon-state.json`

## Installation locale

```powershell
cd addon\scripts
.\install.ps1 -GrocyConfigPath "C:\path\to\grocy\config"
```
