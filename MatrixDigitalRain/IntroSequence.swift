import Cocoa
import CoreText

/// State machine that manages the "Wake up, Neo..." intro sequence.
/// Uses frame counting for deterministic, headless-compatible timing.
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
    private var frameCount: Int = 0
    private var charIndex: Int = 0
    private var nextCharFrame: Int = 0
    private var cursorBlinkFrame: Int = 0
    private var cursorVisible: Bool = true
    private var pauseStartFrame: Int = 0

    private(set) var isComplete: Bool = false

    // MARK: - Precomputed frame counts

    private let initialDelayFrames: Int
    private let framesPerChar: Int
    private let jitterFrames: Int
    private let pauseFrames: [Int]
    private let cursorBlinkFrames: Int

    // MARK: - Init

    init() {
        let fps = MatrixConfig.fps
        initialDelayFrames = max(1, Int(round(MatrixConfig.introInitialDelay * fps)))
        framesPerChar = max(1, Int(round(MatrixConfig.introTypingSpeed * fps)))
        jitterFrames = max(0, Int(round(MatrixConfig.introTypingJitter * fps)))
        pauseFrames = MatrixConfig.introPauseDurations.map { max(1, Int(round($0 * fps))) }
        cursorBlinkFrames = max(1, Int(round(MatrixConfig.introCursorBlinkRate * fps)))
        nextCharFrame = 0
    }

    // MARK: - Update (call once per frame)

    func update() {
        guard !isComplete else { return }
        frameCount += 1

        // Update cursor blink
        if frameCount - cursorBlinkFrame >= cursorBlinkFrames {
            cursorVisible.toggle()
            cursorBlinkFrame = frameCount
        }

        switch phase {
        case .initialDelay:
            if frameCount >= initialDelayFrames {
                startLine(0)
            }

        case .typing(let lineIndex):
            let line = MatrixConfig.introLines[lineIndex]
            if frameCount >= nextCharFrame {
                charIndex += 1
                if charIndex >= line.count {
                    // Line finished typing — transition to pause
                    phase = .pause(lineIndex: lineIndex)
                    pauseStartFrame = frameCount
                    cursorVisible = true
                    cursorBlinkFrame = frameCount
                } else {
                    nextCharFrame = frameCount + framesPerChar + randomJitter()
                }
            }

        case .pause(let lineIndex):
            let pauseDuration = lineIndex < pauseFrames.count ? pauseFrames[lineIndex] : pauseFrames.last!
            if frameCount - pauseStartFrame >= pauseDuration {
                let nextIndex = lineIndex + 1
                if nextIndex < MatrixConfig.introLines.count {
                    startLine(nextIndex)
                } else {
                    // All lines done
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
        phase = .initialDelay
        frameCount = 0
        charIndex = 0
        nextCharFrame = 0
        cursorBlinkFrame = 0
        cursorVisible = true
        pauseStartFrame = 0
        isComplete = false
    }

    // MARK: - Private

    private func startLine(_ lineIndex: Int) {
        let line = MatrixConfig.introLines[lineIndex]
        if MatrixConfig.introInstantLines.contains(lineIndex) {
            // Appear all at once — skip typing, go straight to pause
            charIndex = line.count
            phase = .pause(lineIndex: lineIndex)
            pauseStartFrame = frameCount
            cursorVisible = true
            cursorBlinkFrame = frameCount
        } else {
            phase = .typing(lineIndex: lineIndex)
            charIndex = 0
            nextCharFrame = frameCount + framesPerChar + randomJitter()
            cursorVisible = true
            cursorBlinkFrame = frameCount
        }
    }

    private func randomJitter() -> Int {
        guard jitterFrames > 0 else { return 0 }
        return Int.random(in: -jitterFrames...jitterFrames)
    }
}
