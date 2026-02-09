# Matrix Digital Rain Screensaver

[![CI](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml/badge.svg)](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS_11+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)

A Matrix-style "digital rain" screensaver for macOS featuring real-time rendered falling green characters.

![Matrix Rain Preview](docs/matrix_preview.gif)

## Features

- **Authentic Matrix effect** - Falling characters with glowing heads and fading trails
- **Multi-script characters** - Japanese katakana, Latin, Cyrillic, Korean, Greek, symbols
- **Real-time rendering** - Core Graphics powered, no video files
- **Lightweight** - ~300KB bundle size
- **Adaptive** - Automatically scales to any screen resolution
- **Infinite duration** - No looping, runs forever

## Installation

### Download (Recommended)

1. Download `MatrixDigitalRain.saver.zip` from [Releases](https://github.com/cassmtnr/matrix-macos-screensaver/releases/latest)
2. Unzip and double-click `Matrix Digital Rain.saver`
3. Choose **Install for This User Only** or **Install for All Users**
4. Open **System Settings** → **Screen Saver** and select **Matrix Digital Rain**

### Build from Source

```bash
git clone https://github.com/cassmtnr/matrix-macos-screensaver.git
cd matrix-macos-screensaver

xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Release \
  -derivedDataPath build \
  build

# Install
open "build/Build/Products/Release/Matrix Digital Rain.saver"
```

## Requirements

- macOS 11.0 (Big Sur) or later

## Support

If you enjoy this screensaver, consider [buying me a coffee](https://buymeacoffee.com/cassmtnr)

## License

MIT License - feel free to use, modify, and distribute.
