# Analyse de module

Procédure pour la sous-commande ANALYSE.

## Step 1 : Identifier le module cible

- Argument fourni → utiliser ce module
- Aucun argument → demander : "Quel module analyser ?"
- Vérifier que le module existe via la détection de SKILL.md

## Step 2 : Charger les règles projet

1. Vérifier si `.claude/skills/rules-references/SKILL.md` existe
2. Si oui : lire la table d'index pour identifier les fichiers de règles disponibles
3. Charger `rules.md` (transversal) + les règles spécifiques au domaine du module
4. Si non : noter "Aucune règle projet configurée" — continuer sans vérification de règles

## Step 3 : Dispatcher l'agent d'analyse

```
Agent({
  description: "Analyser le module <nom>",
  subagent_type: "sdd-spec:doc-analyser",
  prompt: "
    Module : <nom>
    Chemin : <path>
    Répertoire de sortie : .specs/doc/modules/<nom>/
    
    Règles projet :
    <contenu de rules.md et règles spécifiques, ou 'Aucune règle projet configurée'>
    
    Générer :
    1. analyse-<nom>.md (template analyse de references/templates.md)
    2. improvement-<nom>.md (template améliorations de references/templates.md)
    3. missing-rules-<nom>.md UNIQUEMENT si des gaps sont trouvés (template règles manquantes)
    
    Templates :
    <insérer les templates pertinents de references/templates.md>
    
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

Regénérer `.specs/doc/index.md` — la section "Analyses disponibles" reflète les nouvelles données.

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
- .specs/doc/modules/<nom>/analyse-<nom>.md
- .specs/doc/modules/<nom>/improvement-<nom>.md
- .specs/doc/modules/<nom>/missing-rules-<nom>.md (si applicable)
```
