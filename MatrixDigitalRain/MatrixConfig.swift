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
    static let startDelay: Double = 4.20 / 2
    static let maxColumnStaggerFrames: Int = 90  // ~3 seconds at 30fps

    // Character set: all 57 printable glyphs from Matrix-Code.ttf
    static let matrixChars: [Character] = Array(
        "モエヤキオカ7ケサスz152ヨタワ4ネヌナ98ヒ0ホア3ウセ¦:\"꞊ミラリ╌ツテニハソ▪コシマムメー©*+<>|\u{E937}"
    )

    static func randomChar() -> Character {
        matrixChars[Int.random(in: 0..<matrixChars.count)]
    }
}
