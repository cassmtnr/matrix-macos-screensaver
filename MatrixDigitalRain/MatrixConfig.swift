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
    static let introInitialDelay: Double = 2.0   // blinking cursor before first line (seconds)
    private static var userName: String {
        let full = NSFullUserName()
        let firstName = full.components(separatedBy: " ").first ?? ""
        return firstName.isEmpty ? "Neo" : firstName
    }
    static var introLines: [String] {
        [
            "Wake up, \(userName)...",
            "The Matrix has you...",
            "Follow the white rabbit.",
            "Knock, knock, \(userName).",
        ]
    }
    static let introInstantLines: Set<Int> = [3]   // line indices that appear all at once (no typing)
    static let introTypingSpeed: Double = 0.1      // 100ms per character
    static let introTypingJitter: Double = 0.03    // ±30ms randomness
    static let introPauseDurations: [Double] = [1.5, 1.5, 1.5, 1.5]  // pause after each line
    static let introCursorBlinkRate: Double = 0.42  // cursor blink interval (seconds)
    static let introFontSize: CGFloat = 18          // smaller terminal-style font

    // Character set: all 57 printable glyphs from Matrix-Code.ttf
    static let matrixChars: [Character] = Array(
        "モエヤキオカ7ケサスz152ヨタワ4ネヌナ98ヒ0ホア3ウセ¦:\"꞊ミラリ╌ツテニハソ▪コシマムメー©*+<>|\u{E937}"
    )

    static func randomChar() -> Character {
        matrixChars[Int.random(in: 0..<matrixChars.count)]
    }
}
