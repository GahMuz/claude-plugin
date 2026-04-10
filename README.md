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

1. `/spec-init` — Initialiser le projet (langages, LSP, configuration)
2. `/spec new <titre>` — Démarrer un nouveau spec
3. Phases séquentielles : Exigences → Conception → Worktree → Planification → Implémentation → Finalisation
4. `/spec approve` — Approuver chaque phase et passer à la suivante

## Commandes principales

| Commande | Description |
|----------|-------------|
| `/spec-init` | Configurer le projet pour le SDD |
| `/spec new <titre>` | Démarrer un nouveau spec |
| `/spec resume [titre]` | Reprendre un spec suspendu |
| `/spec status` | Voir l'état de tous les specs |
| `/spec approve` | Approuver la phase courante |
| `/spec clarify` | Ajouter une clarification (met à jour les documents en place) |
| `/spec suspend` | Suspendre le spec courant |
| `/spec discard` | Abandonner un spec (destructif) |

## Commandes utilitaires

| Commande | Description |
|----------|-------------|
| `/spec-sync <spec-id>` | Synchroniser et corriger le drift spec/code |
| `/continue` | Détecter la prochaine action à effectuer |
| `/document-codebase [module]` | Générer des docs module (économie 80-90% tokens) |
| `/evolve <action>` | Faire évoluer la configuration .claude/ |

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
