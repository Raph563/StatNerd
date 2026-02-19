# StatNerd - Documentation (FR)

StatNerd est un addon avancé pour Grocy.

Depuis la separation 2026-02-19:

- Ce repo `Raph563/Grocy` couvre la ligne core (stats + graphiques).
- Les fonctions produit (OFF/OPF, robot code-barres, photo helpers) sont maintenues dans:
  - `https://github.com/Raph563/Grocy_Product_Helper`

Co-installation (recommande):

- payload core: `config/data/custom_js_nerdstats.html`
- payload product helper: `config/data/custom_js_product_helper.html`
- fichier actif compose: `config/data/custom_js.html`

Les scripts install/update des deux repos gerent automatiquement cette composition.

Fonctionnalités principales:

- Dashboard analytics stock (KPI, graphiques, classements).
- Compatibilité addon assistée:
  - groupes produits
  - entités utilisateur
  - attributs utilisateur
- Outils IA multi-provider.
- Outils de conversion de quantités.
- Workflow de releases GitHub avec alpha automatique et canaux beta/stable.

## Documentation liée

- Guide release: `RELEASING.fr.md`
- Guide débutant: `NOOB_GUIDE.fr.md`
- Pack addon: `../addon/README.fr.md`
- App desktop relay de mise à jour: `https://github.com/Raph563/StatNerd_Update_Relay`
- Version anglaise: `README.en.md`
