#!/usr/bin/swift
// Headless GIF generator — captures frames from an offscreen screensaver view
// and produces an optimized GIF via ffmpeg. Works in CI (no screen recording needed).
//
// Usage:
//   swift generate_preview.swift                              # use defaults
//   swift generate_preview.swift --duration 12 --skip 6       # custom timing
//   swift generate_preview.swift --output docs/matrix_preview.gif
//   swift generate_preview.swift --help
//
// Requirements:
//   - Built .saver bundle (xcodebuild ... -derivedDataPath build build)
//   - ffmpeg (brew install ffmpeg)

import Cocoa
import ScreenSaver

// ── CLI argument parsing ────────────────────────────────────────────────────────

var duration: Double = 30
var skip: Double = 0
var gifWidth: Int = 640
var gifFps: Int = 15
var renderWidth: Int = 1920
var renderHeight: Int = 1080
var output: String = "docs/matrix_preview.gif"

func printUsage() {
    print("""
    Usage: swift generate_preview.swift [OPTIONS]

    Generates a GIF preview of the Matrix screensaver by capturing frames
    from an offscreen window. Runs headlessly — no display or screen
    recording permission required.

    Options:
      --duration SECS      Duration of GIF to capture (default: \(duration))
      --skip SECS          Seconds to skip at start for animation warm-up (default: \(skip))
      --gif-width PIXELS   GIF output width (default: \(gifWidth))
      --gif-fps FPS        GIF frame rate (default: \(gifFps))
      --render-width PX    Render resolution width (default: \(renderWidth))
      --render-height PX   Render resolution height (default: \(renderHeight))
      --output PATH        Output GIF path (default: \(output))
      --help               Show this help message
    """)
}

var argIndex = 1
while argIndex < CommandLine.arguments.count {
    let arg = CommandLine.arguments[argIndex]
    switch arg {
    case "--duration":
        argIndex += 1; duration = Double(CommandLine.arguments[argIndex])!
    case "--skip":
        argIndex += 1; skip = Double(CommandLine.arguments[argIndex])!
    case "--gif-width":
        argIndex += 1; gifWidth = Int(CommandLine.arguments[argIndex])!
    case "--gif-fps":
        argIndex += 1; gifFps = Int(CommandLine.arguments[argIndex])!
    case "--render-width":
        argIndex += 1; renderWidth = Int(CommandLine.arguments[argIndex])!
    case "--render-height":
        argIndex += 1; renderHeight = Int(CommandLine.arguments[argIndex])!
    case "--output":
        argIndex += 1; output = CommandLine.arguments[argIndex]
    case "--help":
        printUsage()
        exit(0)
    default:
        print("Unknown option: \(arg)")
        printUsage()
        exit(1)
    }
    argIndex += 1
}

// ── Load the screensaver bundle ─────────────────────────────────────────────────

let bundlePath = "build/Build/Products/Release/MatrixDigitalRain.saver"
guard let bundle = Bundle(path: bundlePath), bundle.load() else {
    print("Error: Build the project first, then run from the project root:")
    print("  xcodebuild -project MatrixDigitalRain.xcodeproj -scheme MatrixDigitalRain -configuration Release -derivedDataPath build build")
    print("  swift generate_preview.swift")
    exit(1)
}

guard let viewClass = bundle.principalClass as? ScreenSaverView.Type else {
    print("Error: Could not load screensaver view class")
    exit(1)
}

// ── Check ffmpeg ────────────────────────────────────────────────────────────────

func which(_ command: String) -> Bool {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    proc.arguments = ["which", command]
    proc.standardOutput = FileHandle.nullDevice
    proc.standardError = FileHandle.nullDevice
    try? proc.run()
    proc.waitUntilExit()
    return proc.terminationStatus == 0
}

guard which("ffmpeg") else {
    print("Error: ffmpeg is not installed.")
    print("Install it with:  brew install ffmpeg")
    exit(1)
}

// ── Setup offscreen window ──────────────────────────────────────────────────────

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let frame = NSRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
let window = NSWindow(
    contentRect: frame,
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)
window.backgroundColor = .black

let saverView = viewClass.init(frame: frame, isPreview: false)!
saverView.autoresizingMask = [.width, .height]
window.contentView!.addSubview(saverView)
window.orderBack(nil)

saverView.startAnimation()

// ── Frame capture parameters ────────────────────────────────────────────────────

let animFps = 1.0 / saverView.animationTimeInterval          // 30
let frameCaptureInterval = max(1, Int(animFps / Double(gifFps)))  // 2
let totalFrames = Int((skip + duration) * animFps)
let skipFrames = Int(skip * animFps)
let sleepMicros = UInt32(saverView.animationTimeInterval * 1_000_000)

let tempDir = FileManager.default.temporaryDirectory
    .appendingPathComponent("matrix_preview_\(ProcessInfo.processInfo.processIdentifier)")
try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

print("==> Generating preview frames...")
print("    Render: \(renderWidth)x\(renderHeight) @ \(Int(animFps))fps")
print("    Skip: \(skip)s, Capture: \(duration)s")
print("    GIF: \(gifWidth)px @ \(gifFps)fps")
print("    Total simulation: \(String(format: "%.0f", skip + duration))s (\(totalFrames) frames)")

// ── Animation + capture loop ────────────────────────────────────────────────────

var capturedCount = 0

for frameNum in 0..<totalFrames {
    saverView.animateOneFrame()
    saverView.display()
    usleep(sleepMicros)

    // After skip period, capture every Nth frame
    if frameNum >= skipFrames && (frameNum - skipFrames) % frameCaptureInterval == 0 {
        // Render to an explicit 1x CGContext to avoid Retina 2x scaling issues
        let width = renderWidth
        let height = renderHeight
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            print("Warning: Failed to create CGContext for frame \(frameNum)")
            continue
        }

        // Draw the view into our 1x context
        NSGraphicsContext.saveGraphicsState()
        let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.current = nsCtx
        saverView.draw(saverView.bounds)
        NSGraphicsContext.restoreGraphicsState()

        guard let cgImage = ctx.makeImage() else {
            print("Warning: Failed to create CGImage for frame \(frameNum)")
            continue
        }

        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            print("Warning: Failed to create PNG data for frame \(frameNum)")
            continue
        }

        let filename = String(format: "frame_%05d.png", capturedCount)
        try! pngData.write(to: tempDir.appendingPathComponent(filename))
        capturedCount += 1
    }

    // Progress every 5 seconds of simulation
    if frameNum > 0 && frameNum % (Int(animFps) * 5) == 0 {
        let elapsed = Double(frameNum) / animFps
        print("    Progress: \(String(format: "%.0f", elapsed))s / \(String(format: "%.0f", skip + duration))s (\(capturedCount) frames captured)")
    }
}

saverView.stopAnimation()
print("    Captured \(capturedCount) frames")

guard capturedCount > 0 else {
    print("Error: No frames were captured")
    try? FileManager.default.removeItem(at: tempDir)
    exit(1)
}

// ── Generate GIF with ffmpeg (2-pass palette method) ────────────────────────────

print("==> Generating GIF with ffmpeg...")

let outputDir = URL(fileURLWithPath: output).deletingLastPathComponent().path
try! FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

let palette = tempDir.appendingPathComponent("palette.png").path
let inputPattern = tempDir.appendingPathComponent("frame_%05d.png").path

func runFFmpeg(_ arguments: [String]) -> Bool {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    proc.arguments = ["ffmpeg"] + arguments
    try! proc.run()
    proc.waitUntilExit()
    return proc.terminationStatus == 0
}

// Pass 1: generate optimal palette
guard runFFmpeg([
    "-y",
    "-framerate", String(gifFps),
    "-i", inputPattern,
    "-vf", "crop=\(renderWidth/2):\(renderHeight/2):0:0,scale=\(gifWidth):-1:flags=lanczos,palettegen=max_colors=256:stats_mode=full",
    palette,
    "-loglevel", "warning"
]) else {
    print("Error: ffmpeg palette generation failed")
    try? FileManager.default.removeItem(at: tempDir)
    exit(1)
}

// Pass 2: create GIF with palette
guard runFFmpeg([
    "-y",
    "-framerate", String(gifFps),
    "-i", inputPattern,
    "-i", palette,
    "-filter_complex", "[0:v]crop=\(renderWidth/2):\(renderHeight/2):0:0,scale=\(gifWidth):-1:flags=lanczos[s];[s][1:v]paletteuse=dither=sierra2_4a",
    output,
    "-loglevel", "warning"
]) else {
    print("Error: ffmpeg GIF generation failed")
    try? FileManager.default.removeItem(at: tempDir)
    exit(1)
}

// ── Cleanup ─────────────────────────────────────────────────────────────────────

try? FileManager.default.removeItem(at: tempDir)

let attrs = try! FileManager.default.attributesOfItem(atPath: output)
let fileSize = attrs[.size] as! UInt64
let sizeStr: String
if fileSize > 1_048_576 {
    sizeStr = String(format: "%.1fMB", Double(fileSize) / 1_048_576)
} else {
    sizeStr = String(format: "%.0fKB", Double(fileSize) / 1024)
}

print("    GIF saved to \(output) (\(sizeStr))")
print("")
print("Done! Preview your GIF:")
print("  open \(output)")
