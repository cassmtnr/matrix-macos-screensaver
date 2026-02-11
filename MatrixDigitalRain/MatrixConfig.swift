import Foundation

struct MatrixConfig {
    static let fontSize: CGFloat = 20
    static let columnWidth: CGFloat = 24
    static let charChangeProb: Double = 0.02
    static let fps: Double = 30
    static let minTrailLength: Int = 10
    static let maxTrailLength: Int = 31
    static let minSpeed: Double = 0.05
    static let maxSpeed: Double = 0.50
    static let startDelay: Double = 2
    static let maxColumnStaggerFrames: Int = 90  // ~3 seconds at 30fps

    // Intro sequence ("Wake up, Neo...")
    static let introInitialDelay: Double = 3.0   // blinking cursor before first line (seconds)
    static let introLines: [String] = [
        "Wake up, Neo...",          // 15 chars → 2.25s typing + 2.75s pause = 5s
        "The Matrix has you...",    // 21 chars → 3.15s typing + 1.85s pause = 5s
        "Follow the white rabbit.", // 24 chars → 3.60s typing + 1.40s pause = 5s
        "Knock, knock, Neo.",       // instant + 3s pause = 3s
    ]
    static let introInstantLines: Set<Int> = [3]   // line indices that appear all at once (no typing)
    static let introTypingSpeed: Double = 0.15     // 150ms per character
    static let introTypingJitter: Double = 0.03    // ±30ms randomness
    static let introPauseDurations: [Double] = [2.75, 1.85, 1.40, 3.0]  // pause after each line
    static let introCursorBlinkRate: Double = 0.42  // cursor blink interval (seconds)
    static let introFontSize: CGFloat = 16          // smaller terminal-style font

    // Character set: all 57 printable glyphs from Matrix-Code.ttf
    static let matrixChars: [Character] = Array(
        "モエヤキオカ7ケサスz152ヨタワ4ネヌナ98ヒ0ホア3ウセ¦:\"꞊ミラリ╌ツテニハソ▪コシマムメー©*+<>|\u{E937}"
    )

    static func randomChar() -> Character {
        matrixChars[Int.random(in: 0..<matrixChars.count)]
    }
}
