# StatNerd Core (Grocy)

StatNerd Core is now focused on Grocy analytics and dashboard features:
- KPIs
- charts
- rankings
- AI focus overlay
- addon compatibility/update tooling

Product helper features (barcode robot, OFF/OPF product tools, photo helpers) moved to:
- https://github.com/Raph563/Grocy_Product_Helper

## Split Model

- `Raph563/Grocy` => stats/charts core
- `Raph563/Grocy_Product_Helper` => product workflow addon

## Co-Install Support

The install/update scripts now keep each addon isolated and compose the active Grocy payload automatically.

- Core payload file: `config/data/custom_js_nerdstats.html`
- Product payload file: `config/data/custom_js_product_helper.html`
- Active composed file: `config/data/custom_js.html`

So users can install only one addon, or both, without overwriting each other.

## Docs

French:
- `docs/README.fr.md`
- `docs/RELEASING.fr.md`

English:
- `docs/README.en.md`
- `docs/RELEASING.en.md`

## Release channels

- stable: `vX.Y.Z`
- alpha: `vX.Y.Z-alpha.N`
- beta: `vX.Y.Z-beta.N`
