---
allowed-tools: Read, Write, Edit, Glob, Grep
argument-hint: [task description]
description: Start or switch to a new task
---

# Start Task

## Current State
!cat .claude/state/task.md 2>/dev/null || echo "No existing task"

## Your Task

Start or switch to the task: **$ARGUMENTS**

1. Read current state from `.claude/state/task.md`
2. If switching tasks, summarize previous progress
3. Update `.claude/state/task.md` with:
   - Status: In Progress
   - Task description
   - Initial context/understanding
   - Planned next steps

4. Begin working on the task
