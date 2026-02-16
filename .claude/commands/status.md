---
allowed-tools: Read, Glob
description: Show current task and session state
---

# Status Check

## Current Task State
!cat .claude/state/task.md 2>/dev/null || echo "No task in progress"

## Your Response

Provide a concise status update:

1. **Current Task**: What are you working on?
2. **Progress**: What's been completed?
3. **Blockers**: Any issues or questions?
4. **Next Steps**: What's coming up?

Keep it brief - this is a quick check-in.
