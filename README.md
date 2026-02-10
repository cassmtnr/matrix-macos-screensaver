# Matrix Digital Rain Screensaver

[![CI](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml/badge.svg)](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS_11+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/cassmtnr)

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
2. Unzip and double-click `MatrixDigitalRain.saver`
3. Choose **Install for This User Only** or **Install for All Users**
4. Open **System Settings** > **Screen Saver** and select **Matrix Digital Rain**

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
open build/Build/Products/Release/MatrixDigitalRain.saver
```

## Requirements

- macOS 11.0 (Big Sur) or later

## Development

### Project Structure

```
MatrixDigitalRain/
├── MatrixDigitalRain.xcodeproj/
├── MatrixDigitalRain/
│   ├── MatrixConfig.swift       # Configuration constants
│   ├── MatrixColumn.swift       # Falling column logic
│   ├── MatrixDigitalRainView.swift  # Main screensaver view
│   └── Info.plist               # Bundle metadata
├── MatrixDigitalRainTests/      # Unit tests
├── docs/                        # GitHub Pages website
└── .github/workflows/           # CI/CD
```

### Build Commands

```bash
# Build Release
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Release \
  -derivedDataPath build \
  build

# Run Tests
xcodebuild -project MatrixDigitalRain.xcodeproj \
  -scheme MatrixDigitalRain \
  -configuration Debug \
  test

# Clean
xcodebuild -project MatrixDigitalRain.xcodeproj clean
rm -rf build/
```

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## License

MIT License - feel free to use, modify, and distribute.
