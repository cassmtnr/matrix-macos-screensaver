---
allowed-tools: Read, Glob, Grep, Bash(git diff), Bash(git status), Bash(git log)
description: Review code changes for quality, security, and best practices
---

# Code Review

## Changes to Review

!git diff --stat HEAD~1 2>/dev/null || git diff --stat

## Review Process

Analyze all changes for:

### 1. Security (Critical)
- [ ] No secrets/credentials in code
- [ ] Input validation present
- [ ] Output encoding where needed
- [ ] Auth/authz checks on protected routes

### 2. Quality
- [ ] Functions ≤ 20 lines
- [ ] Files ≤ 200 lines
- [ ] No code duplication
- [ ] Clear naming
- [ ] Proper error handling

### 3. Testing
- [ ] Tests exist for new code
- [ ] Edge cases covered
- [ ] Tests are meaningful (not just for coverage)

### 4. Style
- [ ] Matches existing patterns
- [ ] Consistent formatting
- [ ] No commented-out code

## Output Format

For each finding, include file:line reference:

### Critical (Must Fix)
Issues that block merge

### Warning (Should Fix)
Issues that should be addressed

### Suggestion (Consider)
Optional improvements

## Summary

Provide:
1. Overall assessment (Ready / Changes Needed / Not Ready)
2. Count of findings by severity
3. Top priorities to address
