# SDD — Spec Driven Development

Marketplace Claude Code pour le développement spec-driven — un workflow structuré de l'idée au code testé et revu.

## Plugins

| Plugin | Description |
|--------|-------------|
| **sdd-spec** | Workflow complet : exigences → conception → worktree → planification → implémentation → finalisation |
| **sdd-roi** | Mesure du ROI : temps gagné, rentabilité, efficacité du workflow |

## Installation

```bash
# Ajouter le marketplace (une fois)
/plugin marketplace add https://github.com/GahMuz/claude-plugin.git

# Installer les plugins
/plugin install sdd-spec@sdd-marketplace
/plugin install sdd-roi@sdd-marketplace

use option "Install for you (user scope)"
```

## Workflow

1. `/spec-init` — Initialiser le projet (langages, LSP, modèles, configuration)
2. `/spec new <titre>` — Démarrer un nouveau spec
3. Phases séquentielles : Exigences → Conception → Worktree → Planification → Implémentation → Finalisation
4. `/spec approve` — Approuver chaque phase et passer à la suivante

## Commandes spec

| Commande | Description |
|----------|-------------|
| `/spec-init` | Configurer le projet pour le SDD |
| `/spec new <titre>` | Démarrer un nouveau spec |
| `/spec approve` | Approuver la phase courante et passer à la suivante |
| `/spec resume [titre]` | Reprendre une spec : restaure le contexte (context.md / memory) puis reprend le workflow |
| `/spec status` | Voir l'état de tous les specs |
| `/spec clarify` | Ajouter une clarification (met à jour les documents en place) |
| `/spec suspend` | Suspendre le spec courant |
| `/spec discard` | Abandonner un spec (destructif, confirmation requise) |

## Gestion du contexte multi-spec

Plusieurs specs peuvent être en cours simultanément — y compris dans des terminaux différents en parallèle. Chaque terminal maintient son propre contexte de session.

| Commande | Description |
|----------|-------------|
| `/spec recap` | Briefing complet : spec active, phase, décisions clés, questions ouvertes, prochaine action |
| `/spec close` | Sauvegarder le contexte de la session dans la mémoire et désactiver la spec |
| `/spec switch <titre>` | Fermer la spec active (sauvegarde contexte) et reprendre une autre |

Le contexte de chaque spec (décisions clés, fichiers identifiés, questions ouvertes) est persisté sur deux niveaux :
- **`context.md`** dans le répertoire de la spec — commité dans le repo, partagé entre développeurs
- **Memory Claude Code locale** (`spec_<id>.md`) — cache machine, rechargé en priorité si présent

Un autre développeur qui clone le repo et ouvre une spec accède au contexte via `context.md`. La mémoire locale est un cache de confort, pas la source de vérité.

## Division et migration

| Commande | Description |
|----------|-------------|
| `/spec split [<nouveau-titre>]` | Diviser une spec active en deux quand les préoccupations se mélangent — distribue exigences, design, plan et contexte mémoire |
| `/spec-migrate` | Migrer la structure de données du projet vers la version courante du plugin |
| `/spec-migrate --dry-run` | Prévisualiser la migration sans rien modifier |

Lors de la définition des exigences ou du design, le plugin détecte automatiquement les mélanges de préoccupations et propose un split.

## Commandes utilitaires

| Commande | Description |
|----------|-------------|
| `/spec-sync [spec-id]` | Synchroniser et corriger le drift spec/code |
| `/continue` | Détecter la prochaine action à effectuer |
| `/doc <module \| --all \| update \| analyse \| status>` | Documenter et analyser le codebase (économie 80-90% tokens) |
| `/commit [context]` | Commit structuré avec analyse de risque et ruptures |
| `/evolve <action>` | Faire évoluer la configuration .claude/ |

## Structure de données

Le plugin crée et maintient `.sdd/` à la racine du projet :

```
.sdd/
├── config.json          # Configuration projet (langages, modèles, schemaVersion)
├── docs/                # Documentation générée par /doc
│   ├── manifest.json
│   └── modules/
└── specs/
    ├── registry.md      # Index de toutes les specs (actives et terminées)
    └── YYYY/MM/<id>/    # Un répertoire par spec, classé par date
        ├── state.json
        ├── requirement.md
        ├── design.md
        ├── plan.md
        └── reviews/
```

### Versionnage du schéma

`config.json` contient un champ `schemaVersion` qui suit la version du schéma de données. Lors d'une mise à jour du plugin, `/spec-migrate` applique automatiquement les migrations nécessaires. La documentation générée (`/doc`) est automatiquement marquée obsolète après une migration — relancez `/doc update` pour régénérer.

## Principes

- **TDD** — Tests d'abord, toujours
- **SOLID** — Principes de conception respectés et validés
- **Systématique** — Processus structuré, pas d'improvisation
- **Preuves** — Vérifier avant de déclarer succès
- **Parallélisation** — Sous-tâches indépendantes exécutées en parallèle
- **Feedback** — Le développeur sait ce qui se passe à tout moment
- **Apprentissage** — Chaque spec enrichit les règles projet via la rétrospective

## Configuration projet

Après `/spec-init`, personnaliser les règles dans `.claude/skills/rules-references/references/rules.md`.
Les fichiers `rules-*.md` par domaine (controller, service, entity, test...) sont créés automatiquement par la rétrospective à la fin de chaque spec.

## Développement (contributeurs)

Après le clone, activer les hooks git :

```bash
git config core.hooksPath hooks
```

Cela active :
- **pre-commit** : bump automatique de la version mineure dans tous les `plugin.json` et `marketplace.json` ; génère automatiquement un fichier de migration si des fichiers de schéma ont changé
- **post-commit** : tag automatique `vX.Y.Z` sur chaque commit
