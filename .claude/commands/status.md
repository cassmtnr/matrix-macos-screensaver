---
allowed-tools: ["Read", "Glob", "Grep", "Bash(git status)", "Bash(git diff --stat)"]
description: "Show current task and session state"
---

# Status

Show the current state of the project and any active task.

1. Read `.claude/state/task.md` and display the current task (if any)
2. Run `git status` to show the working tree state
3. Run `git diff --stat` to show a summary of changes
4. List recently modified Swift files:
   - Search `MatrixDigitalRain/*.swift` and `MatrixDigitalRainTests/*.swift`
5. Summarize the current state in a concise format:

```
## Current Task
{task description and status, or "No active task"}

## Git Status
{branch, staged/unstaged changes}

## Changed Files
{list of modified files with brief description of changes}
```
