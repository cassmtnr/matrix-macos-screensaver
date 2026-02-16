---
name: code-deduplication
description: Prevent semantic code duplication with capability index
globs:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.py"
---

# Code Deduplication

Prevent semantic duplication by maintaining awareness of existing capabilities.

## Core Principle

```
┌─────────────────────────────────────────────────────────────────┐
│  CHECK BEFORE YOU WRITE                                         │
│  ─────────────────────────────────────────────────────────────  │
│  AI doesn't copy/paste - it reimplements.                       │
│  The problem isn't duplicate code, it's duplicate PURPOSE.      │
│                                                                 │
│  Before writing ANY new function:                               │
│  1. Search codebase for similar functionality                   │
│  2. Check utils/, helpers/, lib/ for existing implementations   │
│  3. Extend existing code if possible                            │
│  4. Only create new if nothing suitable exists                  │
└─────────────────────────────────────────────────────────────────┘
```

## Before Writing New Code

### Search Checklist

1. **Search by purpose**: "format date", "validate email", "fetch user"
2. **Search common locations**:
   - `src/utils/` or `lib/`
   - `src/helpers/`
   - `src/common/`
   - `src/shared/`
3. **Search by function signature**: Similar inputs/outputs

### Common Duplicate Candidates

| Category | Look For |
|----------|----------|
| Date/Time | formatDate, parseDate, isExpired, addDays |
| Validation | isEmail, isPhone, isURL, isUUID |
| Strings | slugify, truncate, capitalize, pluralize |
| API | fetchUser, createItem, handleError |
| Auth | validateToken, requireAuth, getCurrentUser |

## If Similar Code Exists

### Option 1: Reuse directly
```typescript
// Import and use existing function
import { formatDate } from '@/utils/dates';
```

### Option 2: Extend with options
```typescript
// Add optional parameter to existing function
export function formatDate(
  date: Date,
  format: string = 'short',
  locale?: string  // NEW: added locale support
): string { ... }
```

### Option 3: Compose from existing
```typescript
// Build on existing utilities
export function formatDateRange(start: Date, end: Date) {
  return `${formatDate(start)} - ${formatDate(end)}`;
}
```

## File Header Pattern

Document what each file provides:

```typescript
/**
 * @file User validation utilities
 * @description Email, phone, and identity validation functions.
 *
 * Key exports:
 * - isEmail(email) - Validates email format
 * - isPhone(phone, country?) - Validates phone with country
 * - isValidUsername(username) - Checks username rules
 */
```

## Anti-Patterns

- ❌ Writing date formatter without checking utils/
- ❌ Creating new API client when one exists
- ❌ Duplicating validation logic across files
- ❌ Copy-pasting functions between files
- ❌ "I'll refactor later" (you won't)
