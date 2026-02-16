---
allowed-tools: Read, Write, Edit, Glob, Bash(git diff), Bash(git status)
description: Mark current task complete
---

# Complete Task

## Current State
!cat .claude/state/task.md

## Completion Checklist

Before marking complete, verify:

1. [ ] All requirements met
2. [ ] Tests pass (if applicable)
3. [ ] No linting errors
4. [ ] Code reviewed for quality

## Your Task

1. Run final checks (tests, lint)
2. Update `.claude/state/task.md`:
   - Status: **Completed**
   - Summary of what was done
   - Files changed
   - Any follow-up items

3. Show git status/diff for review
