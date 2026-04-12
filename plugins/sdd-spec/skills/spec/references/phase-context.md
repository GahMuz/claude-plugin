# Gestion du contexte de spec (open / close / switch)

Procédures pour sauvegarder et restaurer le contexte de travail d'une spec.
Toute communication en français.

## Deux niveaux de persistance

Le contexte d'une spec est persisté sur **deux niveaux complémentaires** :

| Niveau | Fichier | Portée | Usage |
|--------|---------|--------|-------|
| **Partagé** | `.sdd/specs/YYYY/MM/<id>/context.md` | Commité dans le repo — accessible à tous les développeurs | Source de vérité partagée |
| **Local** | `spec_<id>.md` dans le memory Claude Code | Machine locale uniquement (`~/.claude/projects/`) | Cache de session, rechargement rapide |

**Règle :** `/spec close` écrit les deux. `/spec open` charge depuis le memory local s'il existe, sinon depuis `context.md`, sinon reconstitue depuis `log.md` + `state.json`.

Un développeur qui clone le repo et ouvre une spec verra le contexte via `context.md` — pas le memory local de son collègue.

## Format de `context.md` (fichier repo)

```markdown
# Contexte : <spec-id>

> Phase : <currentPhase>
> Mis à jour : <ISO-8601>

## Objectif
<1-2 phrases rappelant ce que cette spec cherche à accomplir>

## Décisions clés
- <DES-xxx ou REQ-xxx> : <décision prise et justification courte>
- ...

## Fichiers identifiés
- `<chemin>` — <rôle dans la spec>
- ...

## Questions ouvertes
- [ ] <question non résolue impactant la suite>
- ...

## Dernières actions
- <action 1 — brève>
- <action 2 — brève>
```

## Format de l'entrée memory Claude Code (cache local)

**Nom de fichier :** `spec_<spec-id>.md`

```markdown
---
name: Spec : <spec-id>
description: <phase, 2-3 éléments concrets — ex: "phase design, DES-001 approuvé, DES-002 en cours, travail sur Property.php">
type: project
---

<même contenu que context.md>
```

**Règle de description :** doit contenir spec-id, phase, et 2-3 éléments concrets pour que Claude puisse juger la pertinence sans lire le contenu.

## Note multi-terminal

La spec active est trackée en **mémoire de conversation** uniquement — pas dans un fichier partagé. Plusieurs terminaux peuvent travailler sur des specs différentes simultanément sans conflit : chaque session a son propre contexte de conversation, et les fichiers `context.md` sont séparés par spec.

## OPEN

### Step 1 : Identifier la spec
Argument `<name>` fourni → rechercher dans `.sdd/specs/registry.md`.
Pas d'argument → lister les specs non terminées et demander.

### Step 2 : Établir la spec active dans la conversation
Mémoriser en interne : "La spec active dans cette session est `YYYY/MM/<spec-id>`."
Aucun fichier écrit — le tracking est local à cette conversation.

### Step 3 : Charger le contexte (priorité décroissante)

**1. Memory Claude Code local** (`spec_<spec-id>.md`) — si présent, utiliser en priorité (session précédente sur cette machine).

**2. `context.md` dans le repo** (`.sdd/specs/YYYY/MM/<spec-id>/context.md`) — si présent, utiliser (contexte partagé par un collègue ou session précédente).

**3. Reconstitution** — si aucun des deux n'existe : lire `state.json` et `log.md` pour reconstituer l'état et le présenter.

Présenter en français :
```
## Reprise : <spec-id>  [source: memory local | context.md | reconstitué]

Phase : <phase>
Objectif : <objectif>

Décisions clés : ...
Fichiers identifiés : ...
Questions ouvertes : ...
Dernières actions : ...

→ Lancez `/spec approve`, `/spec clarify`, ou continuez le travail.
```

## CLOSE

### Step 1 : Identifier la spec active
Utiliser la spec établie par `/spec open` dans cette session.
Si aucune spec ouverte dans cette session : afficher registry.md et demander quelle spec fermer.

### Step 2 : Synthétiser le contexte
Depuis la conversation courante et les fichiers de la spec (state.json, log.md, requirement.md, design.md) :
- Phase courante
- Objectif
- Décisions clés (session courante + précédentes)
- Fichiers identifiés/modifiés
- Questions ouvertes non résolues
- 3-5 dernières actions significatives

### Step 3 : Écrire `context.md` (repo — partagé)
Écrire `.sdd/specs/YYYY/MM/<spec-id>/context.md` en suivant le format ci-dessus.
Ce fichier sera commité avec le reste de la spec — accessible à tous les développeurs.

### Step 4 : Écrire l'entrée memory Claude Code (local)
Écrire `spec_<spec-id>.md` dans le répertoire memory du projet (même contenu + frontmatter).
Mettre à jour `MEMORY.md` : ajouter ou mettre à jour la ligne :
```
- [Spec : <spec-id>](spec_<spec-id>.md) — <description courte de l'état actuel>
```

### Step 5 : Libérer la spec active dans la conversation
Effacer le tracking interne — plus de spec active dans cette conversation.

### Step 6 : Confirmer
```
Contexte sauvegardé :
- context.md mis à jour (partageable via git)
- Memory local mis à jour (session suivante sur cette machine)

Spec fermée — rouvrez avec `/spec open <spec-id>`.
```

## SWITCH

1. Si une spec est active dans cette session : exécuter CLOSE complet
2. Exécuter OPEN sur la spec demandée

```
Fermeture de <spec-ancienne>... context.md et memory mis à jour.
Ouverture de <spec-nouvelle>...
<afficher contexte restauré>
```

## Impact sur SPLIT

Lors d'un `/spec split`, après création des specs :

1. Lire `context.md` de la spec originale (si existant) ET l'entrée memory locale (si existante)
2. Distribuer les entrées selon les items transférés :
   - **Décisions clés** : associer chaque décision à la spec dont elle couvre les REQ/DES
   - **Fichiers identifiés** : selon le domaine du fichier
   - **Questions ouvertes** : dupliquer si transversales, distribuer si spécifiques
   - **Dernières actions** : conserver dans l'originale, noter l'origine dans la nouvelle
3. Écrire `context.md` dans chaque nouveau répertoire de spec
4. Mettre à jour les entrées memory locales pour les deux specs
5. Mettre à jour MEMORY.md
