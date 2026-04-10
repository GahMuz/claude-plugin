# Phase : Requirements

All questions and output in French.

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
For each identified requirement:
1. Assign next REQ-xxx ID
2. Write user story in French: "En tant que <rôle>, je veux <capacité> afin de <bénéfice>"
3. Write acceptance criteria: specific, testable conditions (in French)
4. Assign priority: obligatoire / souhaitable / optionnel
5. Set status to "brouillon"

### Step 4: Present for Review
Present complete requirement.md to user (in French):
- List all REQ items
- Ask: "Ces exigences couvrent-elles bien votre besoin ? Quelque chose à ajouter, modifier ou retirer ?"
- Iterate until satisfied

### Step 5: Save
Write requirement.md to `.specs/<spec-id>/requirement.md` using template from spec-format skill.
Update state.json: requirements → in-progress.

### Step 6: Await Approval
"Les exigences sont prêtes pour relecture. Quand vous êtes satisfait, lancez `/spec approve` pour passer à la conception."

## Quality Criteria
- Every requirement has a clear user story (in French)
- Acceptance criteria are testable
- No ambiguous language
- Scope is bounded — explicit about exclusions
- Each REQ addresses a single concern
