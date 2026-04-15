# Phase : Framing

All output in French.

## Purpose

Cadrer le problème avant d'explorer les solutions. L'objectif est d'arriver à une définition partagée et précise de la problématique, des contraintes, et de ce qui est hors scope.

## Process

### Step 1: Contexte du problème

Poser les questions suivantes **une par une**, attendre la réponse avant la suivante :

1. "Décrivez le problème en une ou deux phrases. Qu'est-ce qui est cassé, risqué ou bloquant ?"
2. "Quel est l'impact si on ne traite pas ce problème ? (sécurité, maintenance, performance, dette technique...)"
3. "Y a-t-il des contraintes techniques, organisationnelles ou de budget à respecter ?"
4. "Qu'est-ce qui est explicitement hors scope ? (qu'est-ce qu'on ne veut pas traiter dans cet ADR)"

### Step 2: Charger le contexte projet

Avant de cadrer, charger silencieusement le contexte disponible :

- **Docs modules** : lire les fichiers pertinents dans `.sdd/docs/modules/` selon le domaine du problème (ex: si problème de sécurité, chercher `modules/auth/` ou `modules/security/`)
- **Règles** : Glob `**/sdd-rules/SKILL.md` → exécuter le protocole de chargement (plugin + projet + priorité)

⚠ **Les rules sont indicatives dans un ADR.** Elles informent l'analyse mais ne bloquent aucune option. Une décision ADR peut remettre en cause une rule existante — ce sera documenté et validé explicitement en phase decision.

Si des rules ou docs pertinents sont trouvés : en tenir compte dans les questions de framing (ex: si une rule impose un pattern précis, la mentionner comme contrainte existante à discuter).

### Step 3: Vérifier les ADRs liés

Lire `.sdd/decisions/registry.md`. Chercher des ADRs complétés sur un sujet proche.
Si trouvés : "J'ai trouvé des ADRs liés : <liste>. Souhaitez-vous les consulter avant de continuer ?"

### Step 4: Vérifier les specs liées

Lire `.sdd/specs/registry.md` (si existe). Identifier les specs complétées ou en cours sur le même domaine.
Si trouvées : signaler pour contexte.

### Step 5: Écrire framing.md


Écrire `.sdd/decisions/YYYY/MM/<adr-id>/framing.md` :

```markdown
# Framing : <titre>

## Problème
<description du problème>

## Impact si non traité
<conséquences>

## Contraintes
- <contrainte 1>
- <contrainte 2>
- ...

## Non-objectifs (hors scope)
- <ce qu'on ne traitera pas>
- ...

## ADRs liés
- <lien si applicable, sinon "Aucun">

## Specs liées
- <lien si applicable, sinon "Aucune">
```

### Step 6: Présenter et valider

Présenter le framing au format ci-dessus.
"Le cadrage est-il correct ? Souhaitez-vous modifier quelque chose avant de passer à l'exploration des options ?"

Si oui → corriger `framing.md`.
Si prêt → indiquer : "Lancez `/adr approve` pour passer à la phase d'exploration."

### Step 7: Append log.md

```
Phase framing démarrée. Problème : <résumé en 1 ligne>.
```
