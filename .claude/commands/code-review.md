---
allowed-tools: ["Read", "Glob", "Grep", "Bash(git diff)", "Bash(git diff --cached)", "Bash(git status)"]
description: "Review code changes for quality and security"
---

# Code Review

Review current code changes for quality, consistency, and correctness.

1. **Gather changes**:
   - Run `git diff` for unstaged changes
   - Run `git diff --cached` for staged changes
   - Run `git status` for an overview

2. **Review each changed file** against these criteria:

   ### Critical (must fix)
   - Per-frame allocations in `draw()` or `animateOneFrame()` hot paths
   - Frame-count-based timing instead of `Date()` or delta-time
   - Magic numbers not in `MatrixConfig`
   - Missing `@objc(MatrixDigitalRainView)` or `NSPrincipalClass` mismatch
   - Force-unwraps that could crash

   ### Warning (should fix)
   - Missing `///` documentation on public API
   - Missing `// MARK: -` sections
   - Missing test coverage for new behavior
   - Naming doesn't match conventions (PascalCase types, camelCase members)
   - New constants not in `MatrixConfig`

   ### Suggestion (nice to have)
   - Function exceeds 40 lines
   - File exceeds 300 lines
   - Comment describes "what" instead of "why"
   - Opportunity to use `guard` for early return

3. **Output a structured review**:

```
## Code Review Summary

### Files Changed
{list of files with change summary}

### Issues Found

#### Critical
- {file}:{line} — {description}

#### Warnings
- {file}:{line} — {description}

#### Suggestions
- {file}:{line} — {description}

### Verdict
{APPROVE / REQUEST CHANGES / NEEDS DISCUSSION}
```
