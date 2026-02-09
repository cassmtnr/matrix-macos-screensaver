# Matrix Screensaver

[![CI](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml/badge.svg)](https://github.com/cassmtnr/matrix-macos-screensaver/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/cassmtnr/matrix-macos-screensaver/graph/badge.svg)](https://codecov.io/gh/cassmtnr/matrix-macos-screensaver)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com/macos/)
[![Bun](https://img.shields.io/badge/Bun-v1.0+-black.svg)](https://bun.sh)

A Matrix-style "digital rain" screensaver generator for macOS. Creates the iconic falling green characters effect from The Matrix, packaged as a native `.saver` bundle.

![Matrix Rain Effect](matrix_preview.gif)

## Features

- **Authentic Matrix rain effect** with falling characters, glowing heads, and fading trails
- **Multi-script character set**: Japanese katakana, Latin, Cyrillic, Korean, Greek, and symbols
- **Native macOS screensaver** bundle (`.saver`) - no third-party apps needed
- **Configurable**: resolution, duration, FPS, colors, and character sets
- **High quality H.264 video** output with seamless looping

## Requirements

- [Bun](https://bun.sh) (v1.0+)
- [ffmpeg](https://ffmpeg.org) for video encoding
- Xcode Command Line Tools for building the `.saver` bundle

## Installation

```bash
# Clone this repository and cd into it

# Install dependencies
bun install

# Install ffmpeg (macOS)
brew install ffmpeg

# Install Xcode Command Line Tools (if not already installed)
xcode-select --install
```

## Usage

```bash
# Generate the screensaver
bun start
```

This will:
1. Generate 1800 PNG frames (60 seconds at 30 FPS)
2. Encode them into an H.264 video
3. Build the macOS screensaver bundle
4. Output `MatrixSaver.saver` ready for installation

### Installing the Screensaver

- **Double-click** `MatrixSaver.saver` to install, or
- Copy to `~/Library/Screen Savers/` manually

### Activating

1. Open **System Settings** → **Screen Saver**
2. Select **MatrixSaver** from the list

## Configuration

Edit `src/config.ts` to customize:

| Option | Default | Description |
|--------|---------|-------------|
| `WIDTH` | 1920 | Video width in pixels |
| `HEIGHT` | 1080 | Video height in pixels |
| `FPS` | 30 | Frames per second |
| `DURATION_SECONDS` | 60 | Video length (screensaver loops) |
| `FONT_SIZE` | 18 | Character size in pixels |
| `MATRIX_CHARS` | (mixed) | Character set for the rain |
| `COLOR_KEYFRAMES` | Green | Color transitions over time |

### Color Transitions

You can create color transitions by modifying `COLOR_KEYFRAMES`:

```typescript
export const COLOR_KEYFRAMES: ColorKeyframe[] = [
  { time: 0, hue: 120 },    // Start green
  { time: 30, hue: 240 },   // Transition to blue by 30s
  { time: 60, hue: 120 },   // Back to green by 60s
];
```

Hue reference: 0=Red, 60=Yellow, 120=Green, 180=Cyan, 240=Blue, 300=Magenta

## Development

```bash
# Run with watch mode
bun run dev

# Lint code
bun run lint

# Auto-fix lint issues
bun run lint:fix

# Format code
bun run format

# Run tests
bun test
```

## Project Structure

```
matrix-screensaver/
├── src/
│   ├── index.ts          # Main entry point
│   ├── config.ts         # Configuration constants
│   ├── types.ts          # TypeScript interfaces
│   ├── colors.ts         # HSV/RGB conversion, hue interpolation
│   ├── MatrixColumn.ts   # Falling column logic
│   ├── fontLoader.ts     # Font registration
│   ├── frameGenerator.ts # Canvas-based frame rendering
│   ├── videoEncoder.ts   # ffmpeg wrapper
│   ├── bundleBuilder.ts  # xcodebuild wrapper
│   └── __tests__/        # Unit tests
├── MatrixSaver/          # Swift screensaver source
├── MatrixSaver.xcodeproj # Xcode project
├── biome.json            # Linter configuration
├── tsconfig.json         # TypeScript configuration
└── package.json
```

## How It Works

1. **Frame Generation**: Uses [@napi-rs/canvas](https://github.com/Brooooooklyn/canvas) to render each frame with falling characters
2. **Video Encoding**: Pipes PNG frames to ffmpeg for H.264 encoding
3. **Bundle Building**: Compiles the Swift screensaver wrapper with xcodebuild
4. **Video Embedding**: Copies the video into the `.saver` bundle's Resources folder

The screensaver itself is a lightweight Swift app that uses AVPlayer to loop the generated video.

## License

MIT
