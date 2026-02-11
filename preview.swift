#!/usr/bin/swift
// Quick preview app — runs the screensaver view in a regular window
// so you can screen-record it. Usage:
//   swift preview.swift
// Then use Cmd+Shift+5 to record the window.
// Press Cmd+Q to quit.

import Cocoa
import ScreenSaver

// Load the screensaver bundle
let bundlePath = "build/Build/Products/Release/MatrixDigitalRain.saver"
guard let bundle = Bundle(path: bundlePath), bundle.load() else {
    print("Error: Build the project first, then run from the project root:")
    print("  xcodebuild -project MatrixDigitalRain.xcodeproj -scheme MatrixDigitalRain -configuration Release -derivedDataPath build build")
    print("  swift preview.swift")
    exit(1)
}

guard let viewClass = bundle.principalClass as? ScreenSaverView.Type else {
    print("Error: Could not load screensaver view class")
    exit(1)
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let screen = NSScreen.main!
let window = NSWindow(
    contentRect: screen.frame,
    styleMask: [.borderless],
    backing: .buffered,
    defer: false
)
window.level = .normal
window.backgroundColor = .black
window.collectionBehavior = [.fullScreenPrimary]

let saverView = viewClass.init(frame: window.contentView!.bounds, isPreview: false)!
saverView.autoresizingMask = [.width, .height]
window.contentView!.addSubview(saverView)
window.makeKeyAndOrderFront(nil)
window.toggleFullScreen(nil)

saverView.startAnimation()

// Timer to drive animation
Timer.scheduledTimer(withTimeInterval: saverView.animationTimeInterval, repeats: true) { _ in
    saverView.animateOneFrame()
}

app.activate(ignoringOtherApps: true)
app.run()
