---
allowed-tools: ["Read", "Write", "Edit", "Glob"]
description: "Start or switch to a new task"
argument-hint: "<task description>"
---

# Task Management

When this command is invoked with a task description:

1. Read `.claude/state/task.md` to check for an existing active task
2. If an active task exists:
   - Update its status to "Archived" with a completion timestamp
   - Add a separator line
3. Create or update `.claude/state/task.md` with:

```markdown
# Current Task

**Status**: In Progress
**Started**: {current date/time}
**Description**: {the task description from the argument}

## Notes

(none yet)

## Archived Tasks

{previous tasks if any}
```

4. Confirm the task has been recorded and suggest next steps based on the task type:
   - For bug fixes: "Start by reading the relevant source files and reproducing the issue"
   - For features: "Start by reading MatrixConfig.swift and the file where the feature will live"
   - For refactors: "Start by reading the files that will be affected"
