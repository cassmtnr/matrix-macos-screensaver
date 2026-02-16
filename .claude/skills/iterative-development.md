---
name: iterative-development
description: TDD-driven iterative loops until tests pass
globs:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.py"
  - "**/*.go"
---

# Iterative Development (TDD Loops)

Self-referential development loops where you iterate until completion criteria are met.

## Core Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│  ITERATION > PERFECTION                                     │
│  Don't aim for perfect on first try.                        │
│  Let the loop refine the work.                              │
├─────────────────────────────────────────────────────────────┤
│  FAILURES ARE DATA                                          │
│  Failed tests, lint errors, type mismatches are signals.    │
│  Use them to guide the next iteration.                      │
├─────────────────────────────────────────────────────────────┤
│  CLEAR COMPLETION CRITERIA                                  │
│  Define exactly what "done" looks like.                     │
│  Tests passing. Coverage met. Lint clean.                   │
└─────────────────────────────────────────────────────────────┘
```

## TDD Workflow (Mandatory)

Every implementation task MUST follow this workflow:

### 1. RED: Write Tests First
```bash
# Write tests based on requirements
# Run tests - they MUST FAIL
npm test
```

### 2. GREEN: Implement Feature
```bash
# Write minimum code to pass tests
# Run tests - they MUST PASS
npm test
```

### 3. VALIDATE: Quality Gates
```bash
# Full quality check
npm test
```

## Completion Criteria Template

For any implementation task, define:

```markdown
### Completion Criteria
- [ ] All tests passing
- [ ] Coverage >= 80% (on new code)
- [ ] Lint clean (no errors)
- [ ] Type check passing
```

## When to Use This Workflow

| Task Type | Use TDD Loop? |
|-----------|---------------|
| New feature | ✅ Always |
| Bug fix | ✅ Always (write test that reproduces bug first) |
| Refactoring | ✅ Always (existing tests must stay green) |
| Spike/exploration | ❌ Skip (but document findings) |
| Documentation | ❌ Skip |

## Anti-Patterns

- ❌ Writing code before tests
- ❌ Skipping the RED phase (tests that never fail are useless)
- ❌ Moving on when tests fail
- ❌ Large batches (prefer small, focused iterations)
