# Matrix Digital Rain Screensaver

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS_11+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/cassmtnr)

A Matrix-style screensaver for macOS with a personalized intro sequence and real-time falling green characters.

<p align="center">
  <img src="docs/matrix_preview.gif" alt="Matrix Rain Preview" width="100%">
</p>

## Features

- **Personalized intro** — "Wake up, _\<your name\>_..." typed with a blinking cursor, using your Mac username
- **Authentic digital rain** — Matrix-Code font with 57 custom glyphs, glowing white heads and fading green trails
- **Frame-rate independent** — wall-clock timing for the intro, delta-time for the rain. Consistent speed at any FPS
- **Multi-display & adaptive** — scales to any screen resolution across all connected displays

## Installation

### Download

1. Download `MatrixDigitalRain.saver.zip` from [Releases](https://github.com/cassmtnr/matrix-macos-screensaver/releases/latest)
2. Unzip and double-click `MatrixDigitalRain.saver` to install
3. Select it in **System Settings > Screen Saver**

### Build from Source

```bash
git clone https://github.com/cassmtnr/matrix-macos-screensaver.git
cd matrix-macos-screensaver

xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Release \
  -derivedDataPath build \
  build

open build/Build/Products/Release/MatrixDigitalRain.saver
```

Requires macOS 11.0+.

## Development

```bash
# Build
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Release \
  -derivedDataPath build build

# Preview (Cmd+Q to quit)
swift preview.swift
swift preview.swift --duration 30

# Tests
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain -configuration Debug test

# Generate preview GIF (requires ffmpeg)
swift generate_preview.swift --help
```

### Releasing

Distribution builds are signed with a Developer ID Application certificate and notarized so users don't see Gatekeeper warnings. Everything is driven from your local Mac.

One-time setup:

```bash
# Store an App Store Connect API key for notarytool
xcrun notarytool store-credentials "matrix-notary" \
  --key ~/path/to/AuthKey_XXXXXXXX.p8 \
  --key-id <KEY_ID> \
  --issuer <ISSUER_ID>
```

Per release:

```bash
# Build, sign, notarize, staple, zip
./scripts/sign-and-notarize.sh

# Publish (pick the next tag yourself — see latest with: git tag -l 'v*' | sort -V | tail -1)
gh release create vX.Y.Z MatrixDigitalRain.saver.zip --generate-notes
```

To also refresh the preview GIF for the Pages site:

```bash
swift generate_preview.swift --output docs/matrix_preview.gif
```

### Project Structure

```
MatrixDigitalRain/
├── MatrixConfig.swift           # All tunable constants
├── MatrixColumn.swift           # Single falling column logic
├── IntroSequence.swift          # "Wake up..." intro state machine
├── MatrixDigitalRainView.swift  # Main ScreenSaverView subclass
├── Matrix-Code.ttf              # Custom font (57 glyphs)
└── Info.plist
```

## License

MIT
