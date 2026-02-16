---
name: simplicity-rules
description: Enforced code complexity constraints
globs:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.py"
  - "**/*.go"
---

# Simplicity Rules

Complexity is the enemy. Every line of code is a liability.

## Enforced Limits

**CRITICAL: These limits are non-negotiable. Check and enforce for EVERY file.**

### Function Level

| Constraint | Limit | Action if Exceeded |
|------------|-------|-------------------|
| Lines per function | 20 max | Decompose immediately |
| Parameters | 3 max | Use options object |
| Nesting levels | 2 max | Flatten with early returns |

### File Level

| Constraint | Limit | Action if Exceeded |
|------------|-------|-------------------|
| Lines per file | 200 max | Split by responsibility |
| Functions per file | 10 max | Split into modules |

### Module Level

| Constraint | Limit | Reason |
|------------|-------|--------|
| Directory nesting | 3 levels max | Flat is better |
| Circular deps | 0 | Never acceptable |

## Enforcement Protocol

**Before completing ANY file:**

```
1. Count total lines     → if > 200, STOP and split
2. Count functions       → if > 10, STOP and split
3. Check function length → if any > 20 lines, decompose
4. Check parameters      → if any > 3, refactor to options object
```

## Violation Response

When limits are exceeded:

```
⚠️ FILE SIZE VIOLATION DETECTED

[filename] has [X] lines (limit: 200)

Splitting into:
- [filename-a].ts - [responsibility A]
- [filename-b].ts - [responsibility B]
```

**Never defer refactoring.** Fix violations immediately.

## Decomposition Patterns

### Long Function → Multiple Functions

```typescript
// BEFORE: 40 lines
function processOrder(order) {
  // validate... 10 lines
  // calculate totals... 15 lines
  // apply discounts... 10 lines
  // save... 5 lines
}

// AFTER: 4 functions, each < 15 lines
function processOrder(order) {
  validateOrder(order);
  const totals = calculateTotals(order);
  const finalPrice = applyDiscounts(totals, order.coupons);
  return saveOrder({ ...order, finalPrice });
}
```

### Many Parameters → Options Object

```typescript
// BEFORE: 6 parameters
function createUser(name, email, password, role, team, settings) { }

// AFTER: 1 options object
interface CreateUserOptions {
  name: string;
  email: string;
  password: string;
  role?: string;
  team?: string;
  settings?: UserSettings;
}
function createUser(options: CreateUserOptions) { }
```

### Deep Nesting → Early Returns

```typescript
// BEFORE: 4 levels deep
function process(data) {
  if (data) {
    if (data.valid) {
      if (data.items) {
        for (const item of data.items) {
          // actual logic here
        }
      }
    }
  }
}

// AFTER: 1 level deep
function process(data) {
  if (!data?.valid || !data.items) return;

  for (const item of data.items) {
    // actual logic here
  }
}
```

## Anti-Patterns

- ❌ God objects/files (do everything)
- ❌ "Just one more line" (compound violations)
- ❌ "I'll split it later" (you won't)
- ❌ Deep inheritance hierarchies
- ❌ Complex conditionals without extraction
