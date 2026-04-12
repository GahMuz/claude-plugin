# Phase : Requirements

All questions and output in French.

## ⚠️ Règle absolue de format

Le fichier `requirement.md` contient **uniquement** des user stories structurées REQ-xxx.

**INTERDIT dans requirement.md :**
- Spécifications techniques libres (code, SQL, annotations, architecture)
- Détails d'implémentation (noms de classes, schémas de BDD, configurations)
- Critères d'acceptation regroupés en fin de document sans REQ-xxx

**Ces éléments appartiennent à `design.md`** — pas à `requirement.md`.

**Si l'utilisateur fournit d'emblée une description technique détaillée** : extraire les besoins utilisateur sous-jacents et les traduire en user stories REQ-xxx. Les détails techniques seront capturés en phase design.

---

## Process

### Step 1: Understand Context
Read the spec title and any description. Identify domain, likely scope, users/stakeholders.

### Step 2: Ask Clarifying Questions (in French)
Do not assume requirements. Ask specific questions:
- "Que doit-il se passer quand X ?"
- "Qui est l'utilisateur principal de cette fonctionnalité ?"
- "Existe-t-il des patterns existants dans le code pour cela ?"
- "Quels sont les cas limites ?"
- "Qu'est-ce qui ne devrait PAS être dans le périmètre ?"

Ask 3-5 questions at a time. Iterate.

### Step 3: Draft Requirements

Pour chaque exigence identifiée, créer une section REQ-xxx suivant **exactement** ce format :

```markdown
### REQ-001 : <Titre court de l'exigence>

**Récit utilisateur :** En tant que <rôle>, je veux <capacité> afin de <bénéfice>.

**Critères d'acceptation :**
- [ ] <Condition testable 1>
- [ ] <Condition testable 2>
- [ ] <Condition testable 3>

**Priorité :** obligatoire | souhaitable | optionnel

**Statut :** brouillon
```

Règles :
- IDs séquentiels, zéro-paddés à 3 chiffres : REQ-001, REQ-002, …
- Récit utilisateur obligatoire sur chaque REQ, même pour des exigences techniques
- Critères d'acceptation : conditions testables, pas des descriptions d'implémentation
- Une seule préoccupation par REQ

### Step 4: Present for Review
Present complete requirement.md to user (in French):
- List all REQ items
- Ask: "Ces exigences couvrent-elles bien votre besoin ? Quelque chose à ajouter, modifier ou retirer ?"
- Iterate until satisfied

### Step 4b: Concern Detection (after each iteration)
After each round of user input, silently evaluate whether multiple distinct concerns are mixed:
- Different domains (e.g., refactoring existing code + building a new generic system)
- Items that could ship independently with no dependency between them
- Different stakeholders or risk profiles
- "While we're at it" additions that feel like scope creep

**If mixing detected**, add a non-blocking advisory after the requirements list:

```
💡 Ces exigences semblent couvrir deux préoccupations distinctes :
- A : <label> — REQ-001, REQ-002 (refactoring du module existant)
- B : <label> — REQ-003, REQ-004 (nouveau système générique)

Souhaitez-vous séparer B dans une spec dédiée ? (`/spec split` — je ferai la répartition pour vous)
Ou continuer avec tout dans cette spec ?
```

**Avant de proposer un split**, évaluer si les deux préoccupations ont des dépendances mutuelles.
Si oui, signaler immédiatement qu'un découpage A/B naïf créerait un cycle, et proposer directement un découpage en 3 :

```
💡 Ces deux préoccupations sont interdépendantes — un split direct créerait un cycle.
Découpage recommandé en 3 specs :
- A : <domaine sans la partie partagée>
- B-générique : <système autonome sans dépendance>
- B-intégration : <déploiement de B-générique sur A> (dépend de A et B-générique)
```

This is advisory only — never block the user. If they choose to continue, do not raise the concern again unless new conflicting requirements are added.

### Step 5: Save

Write `requirement.md` using the template from `references/templates.md` section `requirement.md`.
Update state.json: requirements → in-progress.
Append log.md entry: date, "Phase exigences", actions (X exigences rédigées), decisions prises.

### Step 6: Await Approval
"Les exigences sont prêtes pour relecture. Quand vous êtes satisfait, lancez `/spec approve` pour passer à la conception."

## Quality Criteria
- Every REQ has a clear user story in French ("En tant que...")
- Acceptance criteria are testable conditions, not implementation descriptions
- No architecture, code, or SQL in requirement.md
- Scope is bounded — explicit about exclusions
- Each REQ addresses a single concern
