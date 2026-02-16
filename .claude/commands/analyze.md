---
allowed-tools: Read, Glob, Grep
argument-hint: [area to analyze]
description: Deep analysis of a specific area
---

# Analyze: $ARGUMENTS

## Analysis Scope

Perform deep analysis of: **$ARGUMENTS**

## Process

1. **Locate relevant files** using Glob and Grep
2. **Read and understand** the code structure
3. **Identify patterns** and conventions
4. **Document findings** with file:line references

## Output Format

### Overview
Brief description of what this area does.

### Key Files
- `path/to/file.ts:10` - Purpose

### Patterns Found
- Pattern 1: Description
- Pattern 2: Description

### Dependencies
What this area depends on and what depends on it.

### Recommendations
Any improvements or concerns noted.
