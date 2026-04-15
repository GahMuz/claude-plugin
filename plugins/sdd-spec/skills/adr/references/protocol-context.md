# Gestion du contexte ADR (open / close / switch)

Procédures pour sauvegarder et restaurer le contexte de travail d'un ADR.
Toute communication en français.

## Deux niveaux de persistance

| Niveau | Fichier | Portée | Usage |
|--------|---------|--------|-------|
| **Partagé** | `.sdd/decisions/YYYY/MM/<id>/context.md` | Commité dans le repo | Source de vérité partagée |
| **Local** | `adr_<id>.md` dans le memory Claude Code | Machine locale uniquement | Cache de session, rechargement rapide |

**Règle :** `/adr close` écrit les deux. `/adr open` charge depuis le memory local s'il existe, sinon depuis `context.md`, sinon reconstitue depuis `log.md` + `state.json`.

## Format de `context.md` (fichier repo)

```markdown
# Contexte ADR : <adr-id>

> Phase : <currentPhase>
> Mis à jour : <ISO-8601>

## Problème
<1-2 phrases rappelant la problématique>

## Options en cours
- <option A> — <statut : en analyse | discutée | rejetée | finaliste | choisie>
- <option B> — ...

## Arguments clés
- <argument important validé pendant la discussion>
- ...

## Contraintes actives
- <contrainte qui influence les options>
- ...

## Questions ouvertes
- [ ] <question non résolue impactant la décision>
- ...

## Dernières actions
- <action 1 — brève>
- <action 2 — brève>
```

## Format de l'entrée memory Claude Code (cache local)

**Nom de fichier :** `adr_<adr-id>.md`

```markdown
---
name: ADR : <adr-id>
description: <phase, 2-3 éléments concrets — ex: "phase discussion, 3 options, Vault favori, question licensing ouverte">
type: project
---

<même contenu que context.md>
```

## Chargement du contexte

### Priorité décroissante

**1. Memory Claude Code local** (`adr_<adr-id>.md`) — si présent, utiliser en priorité.

**2. `context.md` dans le repo** — si présent.

**3. Reconstitution** — lire `state.json` + `log.md` pour reconstituer l'état.

Présenter en français :
```
## Reprise ADR : <adr-id>  [source: memory local | context.md | reconstitué]

Phase : <phase>
Problème : <problème>

Options en cours : ...
Arguments clés : ...
Questions ouvertes : ...
Dernières actions : ...

→ Lancez `/adr approve` pour avancer ou continuez la discussion.
```

## CLOSE

### Step 1 : Identifier l'ADR actif
Lire `.sdd/local/active.json`. Vérifier `type == "adr"`. (Le handler parent a déjà échoué si absent.)

### Step 2 : Synthétiser le contexte
Depuis la conversation courante et les fichiers de l'ADR :
- Phase courante, problème, options et leur statut
- Arguments clés, contraintes actives, questions ouvertes
- 3-5 dernières actions significatives

### Step 3 : Écrire `context.md` (repo — partagé)
Écrire `.sdd/decisions/YYYY/MM/<adr-id>/context.md` en suivant le format ci-dessus.

### Step 4 : Écrire l'entrée memory Claude Code (local)
Écrire `adr_<adr-id>.md` dans le répertoire memory du projet (même contenu + frontmatter).
Mettre à jour `MEMORY.md` :
```
- [ADR : <adr-id>](adr_<adr-id>.md) — <description courte de l'état actuel>
```

### Step 5 : Libérer l'item actif
Supprimer `.sdd/local/active.json`.

### Step 6 : Confirmer
```
Contexte sauvegardé :
- context.md mis à jour (partageable via git)
- Memory local mis à jour (session suivante sur cette machine)

ADR fermé.

⚠ Lancez `/clear` maintenant pour purger le contexte de cette session.
  Rouvrez ensuite avec `/adr open <adr-id>` dans la session propre.
```
