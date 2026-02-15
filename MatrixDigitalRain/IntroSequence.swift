import Cocoa

/// State machine that drives the "Wake up, Neo..." intro sequence.
///
/// Uses wall-clock timing (`Date`) so the intro runs at consistent real-world
/// speed regardless of the actual frame rate. The ScreenSaver framework may
/// call `animateOneFrame()` at varying rates, so we never rely on frame counts.
///
/// ## Phases
/// ```
/// initialDelay → typing(0) → pause(0) → typing(1) → pause(1) → ... → done
/// ```
///
/// Lines with `appearsInstantly: true` skip the typing phase
/// and appear all at once (e.g., "Knock, knock, Neo.").
final class IntroSequence {

    // MARK: - Phase enum

    private enum Phase {
        case initialDelay            // Blinking cursor, no text
        case typing(lineIndex: Int)  // Characters appearing one by one
        case pause(lineIndex: Int)   // Full line visible, waiting
        case done                    // Intro complete, rain can start
    }

    // MARK: - Cached rendering resources (created once, reused every frame)

    private let font: CTFont
    private let textColor: CGColor
    private let glowColor: CGColor

    // MARK: - State

    private var phase: Phase = .initialDelay
    private var startTime = Date()
    private var phaseStartTime = Date()
    private var charIndex = 0
    private var nextCharTime: TimeInterval = 0
    private var lastCursorToggle = Date()
    private var cursorVisible = true

    /// `true` once the entire intro has finished playing.
    private(set) var isComplete = false

    // MARK: - Initialization

    init() {
        let cs = CGColorSpaceCreateDeviceRGB()
        self.font = CTFontCreateWithName("Menlo" as CFString, MatrixConfig.introFontSize, nil)
        self.textColor = CGColor(colorSpace: cs, components: [0, 0.8, 0, 1])!
        self.glowColor = CGColor(colorSpace: cs, components: [0, 0.6, 0, 0.7])!
    }

    // MARK: - Update (call once per frame from animateOneFrame)

    func update() {
        guard !isComplete else { return }

        let now = Date()
        let phaseElapsed = now.timeIntervalSince(phaseStartTime)

        // Toggle cursor visibility on a timer
        if now.timeIntervalSince(lastCursorToggle) >= MatrixConfig.introCursorBlinkRate {
            cursorVisible.toggle()
            lastCursorToggle = now
        }

        switch phase {
        case .initialDelay:
            let elapsed = now.timeIntervalSince(startTime)
            if elapsed >= MatrixConfig.introInitialDelay {
                startLine(0, at: now)
            }

        case .typing(let lineIndex):
            let line = MatrixConfig.introLines[lineIndex]
            // Type all characters whose scheduled time has passed.
            // This handles low frame rates where multiple chars are due per frame.
            while phaseElapsed >= nextCharTime && charIndex < line.text.count {
                charIndex += 1
                if charIndex >= line.text.count {
                    transitionToPause(lineIndex: lineIndex, at: now)
                    break
                }
                nextCharTime += MatrixConfig.introTypingSpeed + randomJitter()
            }

        case .pause(let lineIndex):
            let line = MatrixConfig.introLines[lineIndex]
            if phaseElapsed >= line.pauseDuration {
                let nextIndex = lineIndex + 1
                if nextIndex < MatrixConfig.introLines.count {
                    startLine(nextIndex, at: now)
                } else {
                    phase = .done
                    isComplete = true
                }
            }

        case .done:
            break
        }
    }

    // MARK: - Draw (call from the view's draw method)

    func draw(in context: CGContext, bounds: NSRect) {
        guard !isComplete else { return }
        drawCRTBackground(in: context, bounds: bounds)
        drawText(in: context, bounds: bounds)
        drawScanlines(in: context, bounds: bounds)
    }

    private func drawCRTBackground(in context: CGContext, bounds: NSRect) {
        context.setFillColor(red: 0, green: MatrixConfig.crtBackgroundGlow, blue: 0, alpha: 1)
        context.fill(bounds)
    }

    private func drawText(in context: CGContext, bounds: NSRect) {
        let visibleText = buildDisplayText()
        let displayText = visibleText + (cursorVisible ? "\u{2588}" : " ")

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(cgColor: textColor) ?? NSColor.green
        ]
        let attrString = NSAttributedString(string: displayText, attributes: attributes)
        let ctLine = CTLineCreateWithAttributedString(attrString)

        let lineHeight = MatrixConfig.introFontSize * MatrixConfig.introLineHeightMultiplier
        let y = bounds.height - MatrixConfig.introPadding - lineHeight

        context.saveGState()
        context.setShadow(offset: .zero, blur: MatrixConfig.crtGlowRadius, color: glowColor)
        context.textPosition = CGPoint(x: MatrixConfig.introPadding, y: y)
        CTLineDraw(ctLine, context)
        context.restoreGState()
    }

    private func buildDisplayText() -> String {
        switch phase {
        case .initialDelay, .done: return ""
        case .typing(let i):
            let text = MatrixConfig.introLines[i].text
            return String(text.prefix(min(charIndex, text.count)))
        case .pause(let i):
            return MatrixConfig.introLines[i].text
        }
    }

    private func drawScanlines(in context: CGContext, bounds: NSRect) {
        let spacing = MatrixConfig.crtScanlineSpacing
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: MatrixConfig.crtScanlineAlpha)
        var y: CGFloat = 0
        while y < bounds.height {
            context.addRect(CGRect(x: 0, y: y, width: bounds.width, height: 1))
            y += spacing
        }
        context.fillPath()
    }

    // MARK: - Reset

    /// Resets the intro to the beginning so it can play again.
    func reset() {
        let now = Date()
        phase = .initialDelay
        startTime = now
        phaseStartTime = now
        charIndex = 0
        nextCharTime = 0
        lastCursorToggle = now
        cursorVisible = true
        isComplete = false
    }

    // MARK: - Private helpers

    /// Begins a new line — either types it character by character or shows it instantly.
    private func startLine(_ lineIndex: Int, at now: Date) {
        let line = MatrixConfig.introLines[lineIndex]

        if line.appearsInstantly {
            // Show the entire line at once (e.g., "Knock, knock, Neo.")
            charIndex = line.text.count
            transitionToPause(lineIndex: lineIndex, at: now)
        } else {
            // Begin typing character by character
            phase = .typing(lineIndex: lineIndex)
            phaseStartTime = now
            charIndex = 0
            nextCharTime = MatrixConfig.introTypingSpeed + randomJitter()
            cursorVisible = true
            lastCursorToggle = now
        }
    }

    /// Moves from typing/instant to the pause phase for the given line.
    private func transitionToPause(lineIndex: Int, at now: Date) {
        phase = .pause(lineIndex: lineIndex)
        phaseStartTime = now
        cursorVisible = true
        lastCursorToggle = now
    }

    /// Returns a small random offset to make typing feel natural.
    private func randomJitter() -> TimeInterval {
        guard MatrixConfig.introTypingJitter > 0 else { return 0 }
        return Double.random(in: -MatrixConfig.introTypingJitter...MatrixConfig.introTypingJitter)
    }
}
