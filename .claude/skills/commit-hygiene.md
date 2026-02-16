---
name: commit-hygiene
description: Atomic commits, PR size limits, commit thresholds
globs:
  - "**/*"
---

# Commit Hygiene

Keep commits atomic, PRs reviewable, and git history clean.

## Size Thresholds

| Metric | 🟢 Good | 🟡 Warning | 🔴 Commit Now |
|--------|---------|------------|---------------|
| Files changed | 1-5 | 6-10 | > 10 |
| Lines added | < 150 | 150-300 | > 300 |
| Total changes | < 250 | 250-400 | > 400 |

**Research shows:** PRs > 400 lines have 40%+ defect rates vs 15% for smaller changes.

## When to Commit

### Commit Triggers (Any = Commit)

| Trigger | Action |
|---------|--------|
| Test passes | Just got a test green → commit |
| Feature complete | Finished a function → commit |
| Refactor done | Renamed across files → commit |
| Bug fixed | Fixed the issue → commit |
| Threshold hit | > 5 files or > 200 lines → commit |

### Commit Immediately If

- ✅ Tests are passing after being red
- ✅ You're about to make a "big change"
- ✅ You've been coding for 30+ minutes
- ✅ You're about to try something risky
- ✅ The current state is "working"

## Atomic Commit Patterns

### Good Commits ✅

```
"Add email validation to signup form"
- 3 files: validator.ts, signup.tsx, signup.test.ts
- 120 lines changed
- Single purpose: email validation

"Fix null pointer in user lookup"
- 2 files: userService.ts, userService.test.ts
- 25 lines changed
- Single purpose: fix one bug
```

### Bad Commits ❌

```
"Add authentication, fix bugs, update styles"
- 25 files changed, 800 lines
- Multiple unrelated purposes

"WIP" / "Updates" / "Fix stuff"
- Unknown scope, no clear purpose
```

## Quick Status Check

Run frequently to check current state:

```bash
# See what's changed
git status --short

# Count changes
git diff --shortstat

# Full summary
git diff --stat HEAD
```

## PR Size Rules

| PR Size | Review Time | Quality |
|---------|-------------|---------|
| < 200 lines | < 30 min | High confidence |
| 200-400 lines | 30-60 min | Good confidence |
| 400-1000 lines | 1-2 hours | Declining quality |
| > 1000 lines | Often skipped | Rubber-stamped |

**Best practice:** If a PR will be > 400 lines, split into stacked PRs.
