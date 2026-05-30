# Releasing

This document covers the full process of cutting a release of `MatrixDigitalRain.saver` so end users can install it without Gatekeeper warnings. Everything is driven from a single Mac — there is no CI.

## Overview

A release consists of three artifacts: a **git tag** (`vX.Y.Z`), a **GitHub Release** entry with auto-generated notes, and a **`MatrixDigitalRain.saver.zip`** asset attached to that release. The zip contains the screensaver bundle, code-signed with a Developer ID Application certificate, hardened-runtime-enabled, notarized by Apple, and stapled. Stapling means the bundle works offline — users don't need an internet connection on first launch for Gatekeeper to accept it.

The end-to-end pipeline:

```
xcodebuild Release  →  codesign (Developer ID + --timestamp + hardened runtime)
                  →  zip for notary
                  →  xcrun notarytool submit --wait  →  Apple service: Accepted
                  →  xcrun stapler staple
                  →  distribution zip
                  →  gh release create
```

The `scripts/sign-and-notarize.sh` script drives everything up to the distribution zip; `gh release create` publishes it.

## Prerequisites (one-time setup)

### 1. Developer ID Application certificate

This is the certificate Apple issues for distributing apps *outside* the Mac App Store. It is **not** the same as an "Apple Development" cert (debug) or "Apple Distribution" cert (Mac App Store).

To get one:

1. Visit [Apple Developer → Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click `+`, choose **Developer ID Application** under the "Software" section
3. Follow the CSR flow: open Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority. Use your Apple ID email. "Saved to disk". Upload the resulting `.certSigningRequest` file to the portal.
4. Download the issued `.cer` file and double-click to install in the **login** keychain.

Verify:

```bash
security find-identity -v -p codesigning | grep "Developer ID Application"
```

You should see a line like:

```
1) <SHA1>  "Developer ID Application: Your Name (XXXXXXXXXX)"
```

The team ID in parentheses must match `DEVELOPMENT_TEAM` in `MatrixDigitalRain.xcodeproj/project.pbxproj` (currently `58N4UVGANT`).

### 2. App Store Connect API key

`notarytool` needs an API key to authenticate with Apple's notary service. The key lives in App Store Connect even though this project never touches the App Store — that's just where Apple puts notary credentials.

1. Sign in to [App Store Connect](https://appstoreconnect.apple.com/)
2. **Users and Access → Integrations → Team Keys** (requires Admin or Account Holder role)
3. Click `+`, name it (e.g. "Notary"), Access role **Developer**
4. **Download API Key** — this gives you `AuthKey_XXXXXXXX.p8`. **You can only download once.** If you lose it, generate a new one. Move it to a stable location like `~/Keys/`.
5. Note two values from the key listing page:
   - **Key ID** — ~10-char alphanumeric next to the key (e.g. `W9QG3S4653`)
   - **Issuer ID** — UUID at the top of the page (e.g. `b4a0759f-…`)

### 3. notarytool keychain profile

Store the credentials in your Mac's keychain so the script can use them without re-entering them every time:

```bash
xcrun notarytool store-credentials "matrix-notary" \
  --key ~/Keys/AuthKey_XXXXXXXX.p8 \
  --key-id <KEY_ID> \
  --issuer <ISSUER_ID>
```

Expected output ends with:

```
Validating your credentials...
Success. Credentials validated.
Credentials saved to Keychain.
```

The profile name `matrix-notary` is what `scripts/sign-and-notarize.sh` references — don't rename it without also updating `NOTARY_PROFILE` in the script.

### 4. GitHub CLI

Install and authenticate:

```bash
brew install gh
gh auth login
```

Verify with `gh auth status` — you need write access to the repo to create releases.

### 5. Optional: ffmpeg for preview GIF

If you want to refresh the Pages preview GIF as part of the release:

```bash
brew install ffmpeg
```

## Release procedure

Run on a Mac with the prerequisites above.

### Step 1 — make sure code is ready

The release should be cut from `main` with all intended changes merged. Verify:

```bash
git checkout main
git pull origin main
git status                       # clean working tree
xcodebuild test \
  -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO       # all tests should pass
```

### Step 2 — pick the next version

Semver, prefixed with `v`. Check the latest tag and decide:

```bash
git tag -l 'v*' | sort -V | tail -1
# e.g. v1.0.3 → next patch is v1.0.4, next minor is v1.1.0, next major is v2.0.0
```

Use `MAJOR.MINOR.PATCH`:

- **patch** — bug fixes, internal changes invisible to users
- **minor** — new features that don't break existing usage
- **major** — breaking changes (none expected for a screensaver, but reserve)

### Step 3 — sign, notarize, staple

```bash
./scripts/sign-and-notarize.sh
```

This runs for 2–5 minutes (most of which is waiting on Apple's notary service). The script prints color-coded `==>` headings for each stage. Watch for:

- **Verifying signature** — output should include `Authority=Developer ID Application: …` and `Timestamp=…` (the latter is Apple's secure timestamp, separate from local-clock `Signed Time=…`)
- **Submitting to Apple notary service** — should end with `status: Accepted`. If `Invalid`, the script auto-prints the detailed log and bails before stapling.
- **Stapling notarization ticket** — `The staple and validate action worked!`
- **Verifying Gatekeeper acceptance** — `accepted source=Notarized Developer ID`
- **Distribution archive** — final line names the output zip

Result: `MatrixDigitalRain.saver.zip` at the repo root. This is the file end users will download.

### Step 4 — create the GitHub release

```bash
gh release create vX.Y.Z MatrixDigitalRain.saver.zip --generate-notes
```

Substitute `vX.Y.Z` with the version chosen in Step 2. Flags explained:

- `--generate-notes` — auto-builds release notes from commits since the previous tag
- Without `--draft`, the release publishes immediately
- Add `--target <branch-or-sha>` to tag a non-default-branch commit (rare)
- Add `--latest=false` if cutting a backport that shouldn't appear as "latest"

The command creates the tag remotely on GitHub — you do not need to `git tag` and `git push --tags` separately.

### Step 5 — (optional) refresh the Pages preview GIF

If the visual changed:

```bash
swift generate_preview.swift --output docs/matrix_preview.gif
git add docs/matrix_preview.gif
git commit -m "chore: update preview GIF"
git push origin main
```

GitHub Pages will pick up the new GIF within ~1 minute.

## Verification

After publishing:

1. **Release page** — visit `https://github.com/<owner>/matrix-macos-screensaver/releases/latest`. The download link should resolve to `MatrixDigitalRain.saver.zip` with the size around 100–200 KB.
2. **Pages download button** — `https://<owner>.github.io/matrix-macos-screensaver/` → click "Download". Should navigate to the new release.
3. **Local install smoke test** — download the zip, unzip, double-click the `.saver`, install in System Settings. No "unidentified developer" warning should appear.
4. **Offline-staple check** — copy the unzipped `.saver` to a Mac without internet and verify it still installs (the stapled ticket means Gatekeeper doesn't need to contact Apple).

## Troubleshooting

### `No signing certificate "Developer ID Application" found`

The certificate isn't in the login keychain, or its private key is missing. Re-check Prerequisite #1. If the cert is visible in Keychain Access but not in `security find-identity`, the matching private key is missing — the cert is unusable, and you need to regenerate it on this Mac (the private key never leaves the machine that generated the CSR).

### Notarization returns `status: Invalid`

The script auto-prints the detailed log when this happens. Common causes:

- **"The signature does not include a secure timestamp"** — `--timestamp` was missing. The project's `OTHER_CODE_SIGN_FLAGS = "--timestamp"` should prevent this. If you see it, verify that setting still exists in the Release config of `project.pbxproj`.
- **"The binary is not signed with a valid Developer ID certificate"** — Wrong cert family. The bundle was signed with Apple Development or Apple Distribution instead of Developer ID Application. Re-check `security find-identity` and the project's `CODE_SIGN_IDENTITY` setting.
- **"The hardened runtime is not enabled"** — The project's `ENABLE_HARDENED_RUNTIME = YES` setting got reverted. Verify in the Release config.

You can manually re-fetch any submission's log with:

```bash
xcrun notarytool log <submission-id> --keychain-profile matrix-notary
xcrun notarytool history --keychain-profile matrix-notary   # list recent submissions
```

### `No Keychain password item found for profile: matrix-notary`

The notarytool keychain profile wasn't set up, or was deleted. Re-run Prerequisite #3.

### `gh: command not found` / authentication issues

Install via `brew install gh`, then `gh auth login`. Use HTTPS auth with a token that has `repo` scope.

### Stapling fails with "Record not found"

Means notarization came back `Invalid` but the script continued to stapling. The current script bails out before stapling on `Invalid` status — if you see this, you're on an older version of the script. Pull latest.

### Build succeeds but bundle won't load as a screensaver

If users report the `.saver` installs but System Settings shows it as broken, the bundle may not actually be loadable. Verify locally:

```bash
codesign --verify --strict --verbose=2 build/Build/Products/Release/MatrixDigitalRain.saver
spctl --assess --type install --verbose=2 build/Build/Products/Release/MatrixDigitalRain.saver
```

Both should report success. If `spctl` says "rejected", Gatekeeper sees something wrong — re-check the notarization and stapling output.

## How the pieces fit together

- **Developer ID Application certificate** identifies the publisher (your team `58N4UVGANT`) to macOS Gatekeeper. Without it, distribution outside the Mac App Store triggers "unidentified developer" warnings.
- **Hardened runtime** (`ENABLE_HARDENED_RUNTIME = YES`) is a stricter execution mode for the bundle — it disables a set of behaviors macOS considers risky (DYLD injection, unsigned memory pages, etc.). Apple requires it for notarization since macOS Catalina.
- **Secure timestamp** (`--timestamp`) is a cryptographic timestamp from Apple's timestamp authority server, embedded in the signature. It proves *when* the bundle was signed, so the signature remains valid even after the cert expires for new signing. Notarization rejects bundles without it.
- **Entitlements file** (`MatrixDigitalRain.entitlements`) declares which sandbox capabilities the bundle needs. This project's file is empty — the screensaver doesn't need network, file system, or any other sandbox grants. The file just needs to exist so codesign embeds it.
- **Notarization** is Apple scanning the bundle for malware and known-bad signatures. The notary service returns "Accepted" if clean. Note: it does *not* sign anything; the bundle's signature is unchanged. Notarization is a separate ticket Apple stores in their database.
- **Stapling** (`xcrun stapler staple`) attaches a copy of that notarization ticket directly to the bundle. Without stapling, Gatekeeper has to contact Apple over the network on first launch to verify; stapling makes the bundle work offline.
- **App Store Connect API key** authenticates `notarytool` to Apple's notary service. It has nothing to do with the App Store itself — Apple just chose to put notary credentials there.
- **`matrix-notary` keychain profile** is a local alias storing the API key so commands don't need `--key`, `--key-id`, `--issuer` every time.

## Files involved

| Path | Purpose |
|------|---------|
| `MatrixDigitalRain/MatrixDigitalRain.entitlements` | Empty entitlements plist (required by hardened runtime) |
| `MatrixDigitalRain.xcodeproj/project.pbxproj` | Build settings: `CODE_SIGN_IDENTITY`, `ENABLE_HARDENED_RUNTIME`, `OTHER_CODE_SIGN_FLAGS=--timestamp` (Release config only; Debug stays on automatic Apple Development) |
| `scripts/sign-and-notarize.sh` | One-shot signing pipeline; produces `MatrixDigitalRain.saver.zip` |
| `MatrixDigitalRain.saver.zip` | Distribution artifact (gitignored; uploaded to GitHub Release) |
