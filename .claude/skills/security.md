---
name: security
description: Security patterns and secrets management for this stack
---

# Security

## Gitignore Coverage

The `.gitignore` correctly excludes:
- `build/` and `DerivedData/` — Xcode build artifacts
- `*.xcuserstate` and `xcuserdata/` — Personal Xcode settings
- `*.saver` — Built bundles (distributed via GitHub Releases)
- `.ralph/` — Ralph orchestrator state
- `default.profraw` — Profiling artifacts

## Secrets to Watch For

This project has minimal secrets exposure, but watch for:

| Pattern | Risk | Location |
|---------|------|----------|
| `MATRIX_INTRO_NAME` | Low — only controls display name | `MatrixConfig.swift:59`, `generate_preview.swift:118` |
| System username | Medium — `NSFullUserName()` is read at runtime | `MatrixConfig.swift:62-63` |
| Bundle identifier | Low — public | `Info.plist`, `project.pbxproj` |

## Security Considerations

### Process-scoped font registration
The custom font is registered with `.process` scope (`CTFontManagerRegisterFontsForURL`), meaning it's only available to the screensaver process and doesn't affect other applications. This is the correct approach.

### No network access
The screensaver makes no network calls. It reads only:
- The bundle's own font resource (`Matrix-Code.ttf`)
- The system username (`NSFullUserName()`)
- An optional environment variable (`MATRIX_INTRO_NAME`)

### No user data persistence
The screensaver does not write to disk, store preferences, or access the keychain. `hasConfigureSheet` returns `false`.

### Code signing
The `.saver` bundle is **not code-signed**. Users must remove quarantine with `xattr -cr` after downloading. If code signing is added in the future:
- Never commit signing certificates or provisioning profiles
- Use Xcode automatic signing or CI-provided credentials
- Add `*.p12`, `*.mobileprovision`, `*.certSigningRequest` to `.gitignore`

## OWASP Relevance

Most OWASP Top 10 categories don't apply (no web server, no database, no user input). The primary concern is:
- **A08: Software and Data Integrity** — The unsigned bundle is a trust concern. Users should verify the download hash or build from source.

## Pre-Commit Checks

Before committing, verify:
- No hardcoded paths containing usernames (use `NSFullUserName()` or env vars)
- No secrets in commit messages or comments
- `.gitignore` covers any new build artifacts or generated files
