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
    static let introInitialDelay: Double = 3    // blank screen before first line (seconds)
    static let introLines: [String] = [
        "Wake up, Neo...",
        "The Matrix has you...",
        "Follow the white rabbit.",
        "Knock, knock, Neo.",
    ]
    static let introInstantLines: Set<Int> = [3]   // line indices that appear all at once (no typing)
    static let introTypingSpeed: Double = 0.25     // 336ms per character (~5s for 15-char line)
    static let introTypingJitter: Double = 0.05     // ±50ms randomness
    static let introPauseDurations: [Double] = [2.5, 2.5, 2.5, 2.5]  // pause after each line
    static let introCursorBlinkRate: Double = 0.66  // cursor blink interval (seconds)
    static let introFontSize: CGFloat = 16          // smaller terminal-style font

    // Character set: all 57 printable glyphs from Matrix-Code.ttf
    static let matrixChars: [Character] = Array(
        "モエヤキオカ7ケサスz152ヨタワ4ネヌナ98ヒ0ホア3ウセ¦:\"꞊ミラリ╌ツテニハソ▪コシマムメー©*+<>|\u{E937}"
    )

    static func randomChar() -> Character {
        matrixChars[Int.random(in: 0..<matrixChars.count)]
    }
}
