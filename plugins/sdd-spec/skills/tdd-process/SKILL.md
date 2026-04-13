---
name: TDD Process
description: This skill should be used when "writing tests first", "test-driven development", "TDD", "RED-GREEN-REFACTOR", "TDD cycle", "test file placement", or when implementing subtasks during spec-driven development. Primarily invoked by the task-implementer agent. Covers test-first workflow, commit granularity, and language-agnostic test discovery.
---

# TDD Process

Enforce test-driven development during spec implementation. Apply RED-GREEN-REFACTOR for code changes, with flexibility for non-code tasks.

## The Cycle

### 1. RED — Write a Failing Test

Before any production code:
1. Create or extend a test file (Write for new files, Edit for existing ones)
2. Write a test describing desired behavior
3. Run the test — confirm it **fails**
4. If it passes without new code, the test is not validating new behavior — rewrite

### 2. GREEN — Write Minimal Code

1. Write the minimum code to make the test pass
2. Run the test — confirm it **passes**
3. Run all related tests — confirm nothing broke
4. Fix implementation (not the test) if tests fail

### 3. REFACTOR — Clean Up

With green tests as safety net:
1. Remove duplication, improve naming, simplify
2. Run all tests — confirm still **green**
3. Commit

Never refactor and change behavior simultaneously.

## Commit Granularity

One commit per completed cycle (automated agent commits):
- Format: `feat(TASK-xxx.y): <description>`
- Include test + implementation in the same commit
- Each commit leaves the codebase in a passing state

This format applies to automated commits during TDD cycles. For interactive commits via `/commit`, the commit skill format takes precedence.

## When to Apply Strictly

Full TDD for: new features, business logic, bug fixes, API endpoints, data transformations, database operations.

## When to Be Flexible

Skip RED phase for: config changes, documentation, dependency updates, file renames, boilerplate scaffolding. Still run the full test suite after these changes.

## Language-Agnostic Detection

| Language | Check | Frameworks |
|----------|-------|------------|
| Node/TS | `package.json` scripts.test | jest, mocha, vitest |
| PHP | `composer.json`, `phpunit.xml` | phpunit, pest |
| Java | `pom.xml`, `build.gradle` | junit, testng |

Locate test dirs: `tests/`, `test/`, `__tests__/`, `src/test/`.

## Test File Placement

Follow existing project convention:
- Co-located: `src/module.ts` → `src/module.test.ts`
- Mirror: `src/module.ts` → `tests/src/module.test.ts`
- Java: `src/main/java/...` → `src/test/java/...`
- PHP: `src/Service.php` → `tests/ServiceTest.php`

## Running Tests

Targeted during dev, full suite before commit:
- Node: `npx jest <file>`, `npx vitest run <file>`
- PHP: `./vendor/bin/phpunit --filter <test>`
- Java: `mvn test -Dtest=<Class>`, `./gradlew test --tests <Class>`

## Anti-patterns de test

**1. Tester le comportement du mock**
Si le test passe parce que le mock est présent, pas parce que le code fonctionne — le test est invalide. Tester le comportement réel du composant, pas l'existence du mock.

**2. Méthodes test-only dans les classes de production**
`destroy()`, `reset()`, `cleanup()` qui n'existent que pour les tests n'appartiennent pas à la classe de production. Les mettre dans des test utilities.

**3. Mocker sans comprendre les dépendances**
Avant de mocker une méthode : identifier tous ses side-effects. Si le test dépend d'un de ces side-effects, mocker à un niveau plus bas — pas la méthode elle-même. Mocker "par précaution" casse les tests silencieusement.

## Evidence Over Claims

Never declare "tests pass" without running them. Always execute, read output, confirm, include actual results in the task report.
