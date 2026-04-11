# Statut de la documentation

Procédure pour la sous-commande STATUS.

## Step 1 : Lire le manifest

- Lire `.specs/doc/manifest.json`
- Si absent : "Aucune documentation existante. Lancez `/doc --all` pour démarrer."

## Step 2 : Évaluer la fraîcheur

Pour chaque module et feature, appliquer les règles de fraîcheur de SKILL.md.
Marquer chaque item comme **frais** ou **obsolète** avec la raison.

## Step 3 : Afficher le rapport

```
# Statut de la documentation

> Version skill : 1.0.0
> Manifest : .specs/doc/manifest.json

## Modules

| Module | Features | Fichiers | Générée le | Version | État |
|--------|----------|----------|------------|---------|------|
| <nom> | <count> | <count> | <date> | <version> | Frais / Obsolète (<raison>) |

## Analyses

| Module | Analysée le | Score | Améliorations | État |
|--------|------------|-------|---------------|------|
| <nom> | <date ou "—"> | <score ou "—"> | <count ou "—"> | Frais / Obsolète / Absente |

## Résumé

- Modules documentés : X
- Features documentées : Y
- Documents obsolètes : Z
- Analyses effectuées : W

## Action suggérée

<Si obsolètes : "Lancez `/doc update` pour regénérer les X documents obsolètes.">
<Si aucune analyse : "Lancez `/doc analyse <module>` pour analyser un module.">
<Si tout est frais : "Documentation à jour.">
```
