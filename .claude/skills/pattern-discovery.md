---
name: pattern-discovery
description: Analyze existing codebase to discover and document patterns
globs:
  - "src/**/*"
  - "lib/**/*"
  - "app/**/*"
  - "components/**/*"
  - "pages/**/*"
  - "api/**/*"
  - "services/**/*"
---

# Pattern Discovery

When starting work on a project, analyze the existing code to understand its patterns.

## Discovery Process

### 1. Check for Existing Documentation

```
Look for:
- README.md, CONTRIBUTING.md
- docs/ folder
- Code comments and JSDoc/TSDoc
- .editorconfig, .prettierrc, eslint config
```

### 2. Analyze Project Structure

```
Questions to answer:
- How are files organized? (by feature, by type, flat?)
- Where does business logic live?
- Where are tests located?
- How are configs managed?
```

### 3. Detect Code Patterns

```
Look at 3-5 similar files to find:
- Naming conventions (camelCase, snake_case, PascalCase)
- Import organization (grouped? sorted? relative vs absolute?)
- Export style (named, default, barrel files?)
- Error handling approach
- Logging patterns
```

### 4. Identify Architecture

```
Common patterns to detect:
- MVC / MVVM / Clean Architecture
- Repository pattern
- Service layer
- Dependency injection
- Event-driven
- Functional vs OOP
```

## When No Code Exists

If starting a new project:

1. Ask about preferred patterns
2. Check package.json/config files for framework hints
3. Use sensible defaults for detected stack
4. Document decisions in `.claude/state/task.md`

## Important

- **Match existing patterns** - don't impose new ones
- **When in doubt, check similar files** in the codebase
- **Document as you discover** - note patterns in task state
- **Ask if unclear** - better to ask than assume
