---
allowed-tools: ["Read", "Glob", "Grep"]
description: "Deep analysis of a specific area"
argument-hint: "<area or file path>"
---

# Analyze

Perform a thorough analysis of the specified area of the codebase.

1. **Identify the scope**: Determine what the argument refers to:
   - A file path → analyze that specific file
   - A feature name (e.g., "intro", "rain", "columns") → analyze the relevant files
   - A concept (e.g., "timing", "rendering", "font") → trace it across all files

2. **Read all relevant files**: For the identified scope, read:
   - Source file(s) in `MatrixDigitalRain/`
   - Corresponding test file(s) in `MatrixDigitalRainTests/`
   - Related config entries in `MatrixConfig.swift`

3. **Trace data flow**: Follow how data moves through the system:
   - Where is it created/initialized?
   - Where is it updated?
   - Where is it consumed/rendered?

4. **Identify patterns**: Document:
   - Design patterns used
   - Constants and their relationships
   - State transitions (for state machines)
   - Performance considerations

5. **Output a structured report**:

```
## Analysis: {area}

### Files Involved
| File | Role |
|------|------|
| ... | ... |

### How It Works
{step-by-step explanation of the mechanism}

### Key Constants
| Constant | Value | Purpose |
|----------|-------|---------|
| ... | ... | ... |

### Dependencies
{what this area depends on, and what depends on it}

### Potential Improvements
{any observations about possible enhancements, if relevant}

### Test Coverage
{what's tested, what's not}
```
