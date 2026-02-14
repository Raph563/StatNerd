# Guide Débutant (FR)

Ce guide explique une utilisation standard avec des chemins génériques (pas de chemin machine personnel).

## 1) Préparer le repo

```powershell
cd C:\path\to\repo
git status
```

## 2) Release alpha automatique

Tu n'as plus besoin de lancer la commande alpha manuellement:

- fais ton commit,
- pousse sur `main`,
- le workflow crée automatiquement un tag `vX.Y.Z-alpha.N` puis publie la release.

Commande manuelle alpha (optionnelle):

```powershell
.\scripts\release.ps1 -Version 1.2.1
```

## 3) Faire une beta

```powershell
.\scripts\release.ps1 -Version 1.2.1 -Channel beta
```

## 4) Faire une stable

```powershell
.\scripts\release.ps1 -Version 1.2.1 -Channel stable
```

## 5) Vérifier sur GitHub

1. Ouvrir `Actions` dans le repo.
2. Ouvrir les workflows `Auto Alpha Release` puis `Release`.
3. Vérifier que le job `publish` est vert.
4. Ouvrir `Releases` et vérifier:
   - tag publié,
   - asset ZIP présent.

## 6) Erreurs fréquentes

- `Working tree is not clean`: commit/stash requis.
- `Tag already exists`: utiliser une nouvelle version, ou un autre canal.
- Échec GitHub Actions: vérifier permissions repo/actions/facturation.

## Liens

- Guide release FR: `RELEASING.fr.md`
- Vue d’ensemble FR: `README.fr.md`
- Version EN: `NOOB_GUIDE.en.md`
