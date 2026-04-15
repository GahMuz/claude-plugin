# Analyse de module

Procédure pour la sous-commande ANALYSE.

## Step 1 : Identifier le module cible

- Argument fourni → utiliser ce module
- Aucun argument → demander : "Quel module analyser ?"
- Vérifier que le module existe via la détection de SKILL.md

## Step 2 : Charger les règles

Glob `**/sdd-rules/SKILL.md` → exécuter le protocole de chargement (plugin + projet + priorité).

## Step 3 : Dispatcher l'agent d'analyse

```
Agent({
  description: "Analyser le module <nom>",
  subagent_type: "sdd-spec:doc-analyser",
  model: <from config.models.doc-analyser, default "sonnet">,
  prompt: "
    Module : <nom>
    Chemin : <path>
    Répertoire de sortie : .sdd/docs/modules/<nom>/
    
    Règles projet :
    <règles chargées via sdd-rules (plugin + projet), ou 'Aucune règle configurée'>
    
    Générer :
    1. analyse-<nom>.md
    2. improvement-<nom>.md
    3. missing-rules-<nom>.md UNIQUEMENT si des gaps sont trouvés
    
    Retourner : last_commit hash.
  "
})
```

Si plusieurs modules à analyser (extension future `--all`) : dispatcher un agent par module en parallèle.

## Step 4 : Mettre à jour le manifest

Après réception du résultat :
1. Mettre à jour `modules.<nom>.analysis` avec : `generated_at`, `skill_version`, `last_commit`
2. Écrire le manifest mis à jour

## Step 5 : Mettre à jour l'index

Regénérer `.sdd/docs/index.md` — la section "Analyses disponibles" reflète les nouvelles données.

## Step 6 : Reporter

```
Analyse terminée : <module>

## Résumé
- Anti-patterns : X trouvés
- Approches dépréciées : Y trouvées
- Violations de règles : Z trouvées
- Améliorations suggérées : W (H haute, M moyenne, B basse priorité)
- Règles manquantes : N suggérées (ou "aucune")
- Score : S/100

## Fichiers générés
- .sdd/docs/modules/<nom>/analyse-<nom>.md
- .sdd/docs/modules/<nom>/improvement-<nom>.md
- .sdd/docs/modules/<nom>/missing-rules-<nom>.md (si applicable)
```
