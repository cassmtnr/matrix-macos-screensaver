---
name: testing-methodology
description: Testing patterns and best practices for this project
globs:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/test/**"
  - "**/tests/**"
  - "**/__tests__/**"
---

# Testing Methodology

## Testing Framework

This project uses: **generic**

## The AAA Pattern

Structure every test with:

```
Arrange - Set up test data and conditions
Act     - Execute the code being tested
Assert  - Verify the expected outcome
```

## What to Test

### Must Test
- Core business logic
- Edge cases and boundaries
- Error handling paths
- Public API contracts

### Consider Testing
- Integration points
- Complex conditional logic
- State transitions

### Skip Testing
- Framework internals
- Simple getters/setters
- Configuration constants

## Example Patterns


```
// Add examples for your testing framework here
describe('Component', () => {
  it('should behave correctly', () => {
    // Arrange - set up test conditions
    // Act - execute the code
    // Assert - verify results
  });
});
```

## Test Naming

```
Format: [unit]_[scenario]_[expected result]

Examples:
- calculateTotal_withEmptyCart_returnsZero
- userService_createUser_savesToDatabase
- parseDate_invalidFormat_throwsError
```

## Mocking Guidelines

1. **Mock external dependencies** - APIs, databases, file system
2. **Don't mock what you own** - Prefer real implementations for your code
3. **Keep mocks simple** - Complex mocks often indicate design issues
4. **Reset mocks between tests** - Avoid state leakage

## Coverage Philosophy

- Aim for **80%+ coverage** on critical paths
- Don't chase 100% - it often leads to brittle tests
- Focus on **behavior coverage**, not line coverage
