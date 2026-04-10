---
name: TDD Process
description: This skill should be used when "writing tests first", "test-driven development", "TDD", "RED-GREEN-REFACTOR", "TDD cycle", "run tests", "test file placement", "test commands", or when implementing tasks that require test coverage during spec-driven development. Provides test-first methodology across languages.
---

# TDD Process

Enforce test-driven development during spec implementation. Apply RED-GREEN-REFACTOR for code changes, with flexibility for non-code tasks.

## The Cycle

### 1. RED — Write a Failing Test

Before any production code:
1. Create or extend a test file
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

One commit per completed cycle:
- Format: `feat(TASK-xxx.y): <description>`
- Include test + implementation in the same commit
- Each commit leaves the codebase in a passing state

## When to Apply Strictly

Full TDD for: new features, business logic, bug fixes, API endpoints, data transformations, database operations.

## When to Be Flexible

Skip RED phase for: config changes, documentation, dependency updates, file renames, boilerplate scaffolding. Still run existing tests after these changes.

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

## Evidence Over Claims

Never declare "tests pass" without running them. Always execute, read output, confirm, include actual results in the task report.
