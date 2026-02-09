import Foundation
import AppKit

struct MatrixConfig {
    static let fontSize: CGFloat = 18
    static let columnWidth: CGFloat = 18
    static let charChangeProb: Double = 0.02
    static let hue: CGFloat = 120  // Matrix green (degrees)
    static let fps: Double = 30
    static let minTrailLength: Int = 10
    static let maxTrailLength: Int = 31
    static let minSpeed: Double = 0.3
    static let maxSpeed: Double = 1.0

    // Character set: Katakana, Latin, Cyrillic, Korean, Greek, digits, symbols
    static let matrixChars: [Character] = Array(
        "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン" +
        "ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ" +
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
        "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ" +
        "가나다라마바사아자차카타파하" +
        "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ" +
        "0123456789" +
        ":<>*+=-@#$%&[?]{!}"
    )

    static func randomChar() -> Character {
        matrixChars[Int.random(in: 0..<matrixChars.count)]
    }
}
