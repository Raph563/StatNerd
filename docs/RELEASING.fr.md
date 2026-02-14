# Publier une release (FR)

## Prérequis

- Arbre git propre (`git status` sans modifications).
- Droits push sur `origin`.

## Canaux de release

- `alpha` (automatique sur chaque push `main`): `vX.Y.Z-alpha.N`
- `beta`: `vX.Y.Z-beta.N`
- `stable`: `vX.Y.Z`

## Préparation

1. Mettre à jour `addon/VERSION` (exemple `1.2.1`).
2. Mettre à jour `addon/dist/custom_js.html`:
   - `const ADDON_RUNTIME_VERSION = '1.2.1';`
3. Mettre à jour `CHANGELOG.md`.
4. Commit.

## Alpha automatique (par défaut)

À chaque push sur `main`, le workflow `.github/workflows/auto-alpha-release.yml`:

- lit `addon/VERSION`,
- crée le prochain tag `vX.Y.Z-alpha.N`,
- push le tag,
- puis déclenche `.github/workflows/release.yml` pour publier la release GitHub.

## Lancer une release manuelle (beta/stable)

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

## Ce que font les scripts

- Vérifient que le repo est propre.
- Créent un tag annoté selon le canal.
- Pushent la branche et le tag.

## Publication GitHub

Le workflow `.github/workflows/release.yml`:

- valide `addon/VERSION` contre la version de base du tag,
- génère une archive ZIP du pack addon,
- publie la release GitHub,
- marque automatiquement alpha/beta comme prerelease.

## Liens

- Vue d’ensemble FR: `README.fr.md`
- Guide débutant FR: `NOOB_GUIDE.fr.md`
- Version EN: `RELEASING.en.md`
