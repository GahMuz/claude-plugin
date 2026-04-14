# Phase : Transition

All output in French.

## Purpose

Clore l'ADR et orienter vers la suite : implémentation via spec, autre ADR dépendant, ou archivage pur.

## Process

### Step 1: Lire les prochaines étapes

Lire la section "Prochaines étapes" dans `adr.md`.

### Step 2: Proposer la suite

Présenter les options selon les prochaines étapes identifiées :

**Si une implémentation est nécessaire :**
```
ADR-xxx finalisé ✓

Décision : <option choisie>

Prochaines étapes suggérées :
- `/spec new <titre>` — démarrer l'implémentation (l'ADR servira de contexte pour la phase design)
- `/adr new <titre>` — démarrer un ADR dépendant si une sous-décision est nécessaire
```

**Si aucune implémentation immédiate :**
```
ADR-xxx finalisé ✓

Décision archivée dans .sdd/decisions/YYYY/MM/<adr-id>/adr.md
Consultable via `/adr open <titre>` dans toute future session.
```

### Step 3: Règles impactées

Lire la section "Règles impactées" dans `adr.md`.

Si des rules sont remises en cause :
```
⚠ Cet ADR remet en cause les règles suivantes :
- <rule> dans <fichier> — <résumé de l'impact>

Ces règles doivent être mises à jour pour refléter la nouvelle décision.
Options :
- `/sdd-evolve update` — modifier les rules directement
- `/spec new mise-a-jour-rules-<domaine>` — spec dédié si la mise à jour est complexe
```

Demander : "Souhaitez-vous mettre à jour les rules maintenant ?"
- Si oui → lancer `/sdd-evolve update` avec les rules concernées
- Si non → noter dans `log.md` : "Rules impactées non encore mises à jour : <liste>"

### Step 4: Lien ADR → Spec

Si l'utilisateur lance `/spec new <titre>` après cet ADR, la phase requirements du spec doit charger `adr.md` comme contexte de référence. Rappeler :
"Lors du `/spec new`, mentionnez l'ADR-xxx dans le titre ou la description — le système chargera automatiquement la décision comme contexte pour la phase de design."

### Step 5: Libérer l'item actif

Supprimer `.sdd/local/active.json` — plus d'item actif sur cette machine.
