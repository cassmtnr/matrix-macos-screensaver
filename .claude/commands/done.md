---
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash(git:*)", "Bash(xcodebuild -project MatrixDigitalRain.xcodeproj -scheme MatrixDigitalRain -configuration Debug -derivedDataPath build test)", "Bash(xcodebuild -project MatrixDigitalRain.xcodeproj -scheme MatrixDigitalRain -configuration Release -derivedDataPath build build)"]
description: "Mark current task complete"
---

# Done

Mark the current task as complete after verification.

1. **Run tests**:
   ```bash
   xcodebuild -project MatrixDigitalRain.xcodeproj \
     -scheme MatrixDigitalRain -configuration Debug \
     -derivedDataPath build test
   ```

2. **Build**:
   ```bash
   xcodebuild -project MatrixDigitalRain.xcodeproj \
     -scheme MatrixDigitalRain -configuration Release \
     -derivedDataPath build build
   ```

3. If tests and build pass:
   - Read `.claude/state/task.md`
   - Update the task status to "Done" with a completion timestamp
   - Add a summary of what was accomplished

4. If tests or build fail:
   - Report the failure
   - Do NOT mark the task as done
   - Suggest what needs to be fixed

5. Show a summary:
   ```
   ## Task Complete
   {task description}

   ## What Was Done
   {bullet list of changes}

   ## Verification
   - Tests: ✅ Passed / ❌ Failed
   - Build: ✅ Passed / ❌ Failed

   ## Suggested Next Steps
   {any follow-up items}
   ```
