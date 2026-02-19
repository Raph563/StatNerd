# StatNerd - Documentation (EN)

StatNerd is an advanced addon for Grocy.

Since the 2026-02-19 split:

- This `Raph563/Grocy` repo covers the core line (stats + charts).
- Product workflows (OFF/OPF, barcode robot, photo helpers) are maintained in:
  - `https://github.com/Raph563/Grocy_Product_Helper`

Co-installation (recommended):

- core payload: `config/data/custom_js_nerdstats.html`
- product-helper payload: `config/data/custom_js_product_helper.html`
- composed active file: `config/data/custom_js.html`

Install/update scripts in both repositories now handle this composition automatically.

Main capabilities:

- Stock analytics dashboard (KPIs, charts, rankings).
- Guided addon compatibility:
  - product groups
  - user entities
  - user fields
- Multi-provider AI tooling.
- Quantity conversion tooling.
- GitHub release workflow with automatic alpha and beta/stable channels.

## Related docs

- Release guide: `RELEASING.en.md`
- Beginner guide: `NOOB_GUIDE.en.md`
- Addon pack: `../addon/README.en.md`
- Desktop update relay app: `https://github.com/Raph563/StatNerd_Update_Relay`
- French version: `README.fr.md`
