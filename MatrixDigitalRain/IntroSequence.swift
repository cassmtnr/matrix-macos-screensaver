import Cocoa
import CoreText

/// State machine that manages the "Wake up, Neo..." intro sequence.
/// Uses wall-clock timing so the intro runs at consistent real-world speed
/// regardless of the actual frame rate.
class IntroSequence {

    // MARK: - Types

    private enum Phase {
        case initialDelay
        case typing(lineIndex: Int)
        case pause(lineIndex: Int)
        case done
    }

    // MARK: - State

    private var phase: Phase = .initialDelay
    private var startTime: Date = Date()
    private var phaseStartTime: Date = Date()
    private var charIndex: Int = 0
    private var nextCharTime: TimeInterval = 0
    private var lastCursorToggle: Date = Date()
    private var cursorVisible: Bool = true

    private(set) var isComplete: Bool = false

    // MARK: - Update (call once per frame)

    func update() {
        guard !isComplete else { return }
        let now = Date()
        let elapsed = now.timeIntervalSince(startTime)
        let phaseElapsed = now.timeIntervalSince(phaseStartTime)

        // Update cursor blink
        if now.timeIntervalSince(lastCursorToggle) >= MatrixConfig.introCursorBlinkRate {
            cursorVisible.toggle()
            lastCursorToggle = now
        }

        switch phase {
        case .initialDelay:
            if elapsed >= MatrixConfig.introInitialDelay {
                startLine(0, at: now)
            }

        case .typing(let lineIndex):
            let line = MatrixConfig.introLines[lineIndex]
            if phaseElapsed >= nextCharTime {
                charIndex += 1
                if charIndex >= line.count {
                    phase = .pause(lineIndex: lineIndex)
                    phaseStartTime = now
                    cursorVisible = true
                    lastCursorToggle = now
                } else {
                    nextCharTime = phaseElapsed + MatrixConfig.introTypingSpeed + randomJitter()
                }
            }

        case .pause(let lineIndex):
            let pauseDuration = lineIndex < MatrixConfig.introPauseDurations.count
                ? MatrixConfig.introPauseDurations[lineIndex]
                : MatrixConfig.introPauseDurations.last!
            if phaseElapsed >= pauseDuration {
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

    // MARK: - Draw (call from view's draw method)

    func draw(in context: CGContext, bounds: NSRect) {
        guard !isComplete else { return }

        let fontSize = MatrixConfig.introFontSize
        let font = CTFontCreateWithName("Menlo" as CFString, fontSize, nil)
        let green = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0, 0.8, 0, 1])!

        let currentLine: String
        let displayLength: Int

        switch phase {
        case .initialDelay:
            currentLine = ""
            displayLength = 0
        case .typing(let lineIndex):
            currentLine = MatrixConfig.introLines[lineIndex]
            displayLength = min(charIndex, currentLine.count)
        case .pause(let lineIndex):
            currentLine = MatrixConfig.introLines[lineIndex]
            displayLength = currentLine.count
        case .done:
            return
        }

        // Build the visible text
        let visibleText = String(currentLine.prefix(displayLength))
        let displayText = cursorVisible ? visibleText + "\u{2588}" : visibleText + " "

        // Create attributed string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(cgColor: green) ?? NSColor.green
        ]
        let attrString = NSAttributedString(string: displayText, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attrString)

        // Position: top-left, terminal style
        let padding: CGFloat = 40
        let lineHeight = fontSize * 1.4
        let y = bounds.height - padding - lineHeight

        context.saveGState()
        context.textPosition = CGPoint(x: padding, y: y)
        CTLineDraw(line, context)
        context.restoreGState()
    }

    // MARK: - Reset

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

    // MARK: - Private

    private func startLine(_ lineIndex: Int, at now: Date) {
        let line = MatrixConfig.introLines[lineIndex]
        if MatrixConfig.introInstantLines.contains(lineIndex) {
            charIndex = line.count
            phase = .pause(lineIndex: lineIndex)
            phaseStartTime = now
            cursorVisible = true
            lastCursorToggle = now
        } else {
            phase = .typing(lineIndex: lineIndex)
            phaseStartTime = now
            charIndex = 0
            nextCharTime = MatrixConfig.introTypingSpeed + randomJitter()
            cursorVisible = true
            lastCursorToggle = now
        }
    }

    private func randomJitter() -> TimeInterval {
        guard MatrixConfig.introTypingJitter > 0 else { return 0 }
        return Double.random(in: -MatrixConfig.introTypingJitter...MatrixConfig.introTypingJitter)
    }
}
