---
name: systematic-debugging
description: Methodical approach to finding and fixing bugs
globs:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
---

# Systematic Debugging

A 4-phase methodology for finding and fixing bugs efficiently.

## Phase 1: Reproduce

Before fixing, confirm you can reproduce the bug.

```
1. Get exact steps to reproduce
2. Identify expected vs actual behavior
3. Note any error messages verbatim
4. Check if it's consistent or intermittent
```

## Phase 2: Locate

Narrow down where the bug occurs.

```
Techniques:
- Binary search through code flow
- Add logging at key points
- Check recent changes (git log, git diff)
- Review stack traces carefully
- Use debugger breakpoints
```

## Phase 3: Diagnose

Understand WHY the bug happens.

```
Questions:
- What assumptions are being violated?
- What state is unexpected?
- Is this a logic error, data error, or timing issue?
- Are there edge cases not handled?
```

## Phase 4: Fix

Apply the minimal correct fix.

```
Guidelines:
- Fix the root cause, not symptoms
- Make the smallest change that fixes the issue
- Add a test that would have caught this bug
- Check for similar bugs elsewhere
- Update documentation if needed
```

## Quick Reference

| Symptom | Check First |
|---------|-------------|
| TypeError | Null/undefined values, type mismatches |
| Off-by-one | Loop bounds, array indices |
| Race condition | Async operations, shared state |
| Memory leak | Event listeners, subscriptions, closures |
| Infinite loop | Exit conditions, recursive calls |
