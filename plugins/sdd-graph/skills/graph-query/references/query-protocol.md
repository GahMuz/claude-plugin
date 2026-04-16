# Protocole de réponse aux requêtes graphe

Procédure pour l'agent `graph-query`. Lire uniquement les artifacts `.sdd/graph/`. Ne pas scanner le code source.

## Step 1 : Classifier la question

Détecter le type de requête depuis les mots-clés :

| Mots-clés détectés | Type | Graphes à lire |
|--------------------|------|----------------|
| "dépend de", "qui utilise", "caller", "appelle", "blast radius" | IMPACT | `service-call.json`, `module-dep.json` |
| "chemin", "stack", "flux", "endpoint", "route", "GET/POST/..." | FLOW | `endpoint-flow.json` |
| "entité", "table", "modèle", "champs", "relation" | ENTITY | `entity-model.json` |
| "module", "couplage", "dépendances inter", "afférent", "efférent" | MODULE | `module-dep.json` |
| "service", "repository", "injection" | SERVICE | `service-call.json` |
| tous les endpoints, liste | LIST | `endpoint-flow.json` |

Si ambigu → lire les deux graphes les plus probables.

## Step 2 : Extraire la slice pertinente

**NE PAS** retourner le fichier JSON complet. Extraire uniquement les entrées pertinentes.

### Pour IMPACT — "qui dépend de X ?"

1. Lire `service-call.json`
2. Dans `nodes` : trouver le nœud dont `name` correspond à X
3. Dans `edges` : trouver toutes les edges où `to == id_de_X` → ce sont les **callers directs**
4. Pour chaque caller : récupérer son `name` et `file`
5. Lire `module-dep.json` : trouver les modules qui ont X dans leur `dependsOn`

Réponse :
```
## Impact : <X>

**Callers directs (service-call) :**
- <ServiceA> (`<file>`) — injection dans constructeur, ligne <callSite>
- <ServiceB> (`<file>`) — injection @Autowired

**Modules dépendants (module-dep) :**
- <module_A> (couplage : <N> imports)
- <module_B> (couplage : <M> imports)

**Recommandation :** Toute modification de <X> impacte potentiellement <N> services et <M> modules.
```

### Pour FLOW — chemin d'un endpoint

1. Lire `endpoint-flow.json`
2. Trouver l'endpoint dont `method` + `path` correspond (accepter correspondance partielle sur le path)
3. Retourner la chaîne complète

Réponse :
```
## Flux : <METHOD> <path>

**Chaîne d'appel :**
endpoint → <ControllerClass>#<method> (`<file>:<line>`)
         → <ServiceClass>#<method> (`<file>:<line>`)
         → <RepositoryClass> (`<file>`)
         → Entité : <EntityName> — Table : <table>

**DTO entrée :** <requestDto ou "aucun">
**DTO sortie :** <responseDto>
**Sécurité :** <security ou "aucune">
```

### Pour ENTITY — définition d'une entité

1. Lire `entity-model.json`
2. Trouver l'entité dont `name` correspond (insensible à la casse)
3. Retourner la définition complète

Réponse :
```
## Entité : <Name>

**Table :** `<table>` | **Module :** `<module>`
**Fichier :** `<file>`

**Champs :**
| Champ | Type | Colonne | Annotations |
|-------|------|---------|-------------|
| <name> | <type> | <column> | <annotations> |

**Relations :**
| Type | Cible | mappedBy | Fetch |
|------|-------|----------|-------|
| ONE_TO_MANY | Order | user | LAZY |
```

### Pour MODULE — dépendances inter-modules

1. Lire `module-dep.json`
2. Trouver le ou les modules mentionnés
3. Retourner `dependsOn`, `usedBy`, et les poids de couplage

Réponse :
```
## Module : <name>

**Dépend de :** <mod_A> (poids: 12), <mod_B> (poids: 3)
**Utilisé par :** <mod_C> (poids: 5), <mod_D> (poids: 8)

**Couplage total afférent :** <somme des usedBy>
**Couplage total efférent :** <somme des dependsOn>
```

### Pour LIST — liste d'endpoints

1. Lire `endpoint-flow.json`
2. Filtrer selon les critères de la question (module, méthode HTTP, sécurité, etc.)
3. Retourner un tableau

Réponse :
```
## Endpoints <filtre>

| Méthode | Path | Controller | Sécurité |
|---------|------|-----------|----------|
| GET | /api/v1/users | UserController#getUsers | ROLE_USER |
| POST | /api/v1/users | UserController#createUser | ROLE_ADMIN |
```

## Step 3 : Indiquer les limites

Toujours terminer par :

```
**Source :** <nom_graphe>.json (construit le <builtAt>, commit <lastCommit[:7]>)
**Confiance :** exacte | approximative | partielle
```

- `exacte` : correspondance directe trouvée dans le graphe
- `approximative` : correspondance par pattern matching (ex: path avec variables)
- `partielle` : graphe incomplet ou `status: "partial"` dans le manifest

Si le graphe est `stale` → ajouter : "⚠ Graphe obsolète — relancer `/graph-build --java` pour des résultats à jour."

## Format général de réponse

- 10-30 lignes maximum (sauf listes exhaustives explicitement demandées)
- Pas de JSON brut dans la réponse — toujours reformaté en tableau ou liste bullet
- Inclure toujours les chemins de fichiers pour permettre la navigation directe
- En français
