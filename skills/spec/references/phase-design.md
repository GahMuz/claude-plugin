# Phase : Design

All output in French.

## Process

### Step 1: Read Requirements
Load `.specs/<spec-id>/requirement.md`. Understand all REQ items and acceptance criteria.

### Step 2: Check Project Rules
Search for `.claude/skills/rules-references/SKILL.md`:
- Found → read and apply project rules during design
- Not found → proceed without project-specific constraints

### Step 3: Design Each Requirement Group
For each logical group of related requirements:
1. Assign DES-xxx ID
2. Describe problem (in French)
3. Propose approach with rationale
4. Consider 2-3 alternatives with rejection reasons
5. Note tradeoffs
6. List: `Implémente : [REQ-001, REQ-002]`

### Step 4: Explore Alternatives (in French)
For non-trivial decisions, present options:
- "Option A : <approche> — avantages : ..., inconvénients : ..."
- "Option B : <approche> — avantages : ..., inconvénients : ..."
- "Je recommande l'option A car..."
- Let user decide

### Step 5: Validate Against SOLID Principles

Every design section must be checked against SOLID:

- **S — Single Responsibility** : Chaque module/classe a une seule raison de changer
- **O — Open/Closed** : Ouvert à l'extension, fermé à la modification
- **L — Liskov Substitution** : Les sous-types doivent être substituables à leurs types de base
- **I — Interface Segregation** : Préférer plusieurs interfaces spécifiques à une interface générale
- **D — Dependency Inversion** : Dépendre d'abstractions, pas d'implémentations concrètes

For each DES section, verify the approach respects these principles. If a violation is found, revise the design or document the justified exception.

### Step 6: Validate Against Project Rules
If rules-references skill is available:
- Check design against project conventions
- Verify technology choices align with project stack
- Confirm architectural patterns match

**If SOLID conflicts with a project rule:**
Do NOT silently choose one over the other. Present the conflict to the user in French:
- "Conflit détecté entre les principes SOLID et les règles projet :"
- Explain the SOLID principle at stake
- Explain the project rule that contradicts it
- "Quelle direction souhaitez-vous prendre ?"
- Wait for user decision before proceeding

### Step 7: Present Design
Present complete design.md (in French):
- All DES items with approaches and rationale
- Cross-references to REQs
- SOLID compliance notes
- "Cette conception vous convient-elle ? Des sections à revoir ?"

### Step 8: Generate Coverage Mapping
Add a "Couverture des exigences" table at the end of design.md:
- List every REQ-xxx
- Map to which DES-xxx covers it
- Mark ✅ if covered, ❌ if not
- Any ❌ must be addressed before approval

### Step 9: Save
Write design.md using template. Update state.json.

### Step 10: Await Approval
"La conception est prête pour relecture. Lancez `/spec approve` pour passer à la planification."

## Quality Criteria
- Coverage mapping table complete (no ❌)
- Every REQ addressed by >= 1 DES
- SOLID principles respected (or exceptions justified)
- Alternatives genuinely considered
- Tradeoffs honestly stated
- Implementable in small tasks
- Project rules respected (conflicts resolved with user)
