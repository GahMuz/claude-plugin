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
Check `.specs/config.json` for `richRequirements` setting.

**Standard format** (default, `richRequirements: false`):
For each identified requirement:
1. Assign next REQ-xxx ID
2. Write user story in French: "En tant que <rôle>, je veux <capacité> afin de <bénéfice>"
3. Write acceptance criteria: specific, testable conditions (in French)
4. Assign priority: obligatoire / souhaitable / optionnel
5. Set status to "brouillon"

**Rich format** (opt-in, `richRequirements: true`):
Organize requirements in three layers:
1. **Scénarios utilisateur (BDD)** — US-1, US-2, etc.:
   ```
   ### US-1 : <Titre du scénario>
   **Étant donné** <contexte initial>
   **Quand** <action utilisateur>
   **Alors** <résultat attendu>
   **Critères d'acceptation :**
   - [ ] <condition testable>
   ```
2. **Exigences fonctionnelles** — FR-001, FR-002, etc.:
   ```
   **FR-001 [OBLIGATOIRE]** : <exigence concrète>
   **FR-002 [SOUHAITABLE]** : <exigence concrète>
   ```
3. **Critères de succès** — SC-001, SC-002, etc.:
   ```
   **SC-001** : <résultat mesurable>
   ```

In rich mode, REQ-xxx IDs still apply. US/FR/SC are sub-items within each REQ.

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
