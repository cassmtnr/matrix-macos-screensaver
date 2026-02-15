import Foundation

/// Central configuration for the Matrix Digital Rain screensaver.
/// All tunable constants live here for easy adjustment.
///
/// Uses a caseless `enum` instead of a `struct` to prevent accidental
/// instantiation — this is a pure namespace for static constants.
enum MatrixConfig {

    // MARK: - Rain rendering

    static let fontSize: CGFloat = 20
    static let columnWidth: CGFloat = 24
    static let fps: Double = 30

    /// Probability that any single character mutates on a given frame,
    /// creating the "glitch" effect. Applied independently to each cell.
    static let perCellMutationChance: Double = 0.02

    /// Brightness threshold at which a character is rendered as white (the "head").
    /// Slightly below 1.0 to account for floating-point imprecision in trail calculations.
    static let headBrightnessThreshold: Double = 0.95

    /// Extra rows beyond the visible area, so trails starting above the
    /// screen have character data ready before they scroll into view.
    static let offScreenRowBuffer: Int = 5

    // MARK: - Column behavior

    static let minTrailLength: Int = 10
    static let maxTrailLength: Int = 31
    static let minSpeed: Double = 0.05
    static let maxSpeed: Double = 0.50

    /// Maximum random delay (in seconds) before a column starts falling.
    /// Creates the staggered "wave" effect when the rain begins.
    static let maxColumnStaggerDelay: Double = 3.0

    // MARK: - Intro sequence ("Wake up, Neo...")

    /// Configuration for a single intro line.
    struct IntroLine {
        /// The text to display.
        let text: String
        /// Seconds to pause after this line finishes typing.
        let pauseDuration: Double
        /// If `true`, the line appears all at once instead of being typed.
        let appearsInstantly: Bool
    }

    /// Seconds the blinking cursor is shown before the first line starts typing.
    static let introInitialDelay: Double = 2.0

    /// The user's first name, used to personalize intro lines.
    /// Falls back to "Neo" if the system username is unavailable.
    /// Can be overridden via the `MATRIX_INTRO_NAME` environment variable
    /// (used by generate_preview.swift to show "Neo" in the public GIF).
    private static let userName: String = {
        if let override = ProcessInfo.processInfo.environment["MATRIX_INTRO_NAME"], !override.isEmpty {
            return override
        }
        let fullName = NSFullUserName()
        let firstName = fullName.components(separatedBy: " ").first ?? ""
        return firstName.isEmpty ? "Neo" : firstName
    }()

    /// The lines displayed during the intro sequence.
    /// Each line defines its text, pause duration, and whether it types or appears instantly.
    static let introLines: [IntroLine] = [
        IntroLine(text: "Wake up, \(userName)...",       pauseDuration: 1.5, appearsInstantly: false),
        IntroLine(text: "The Matrix has you...",          pauseDuration: 1.5, appearsInstantly: false),
        IntroLine(text: "Follow the white rabbit.",       pauseDuration: 1.5, appearsInstantly: false),
        IntroLine(text: "Knock, knock, \(userName).",     pauseDuration: 1.5, appearsInstantly: true),
    ]

    /// Seconds between each typed character.
    static let introTypingSpeed: Double = 0.1

    /// Random jitter added to typing speed (±seconds) for a natural feel.
    static let introTypingJitter: Double = 0.03

    /// Cursor blink interval in seconds.
    static let introCursorBlinkRate: Double = 0.42

    // MARK: - CRT monitor effects (intro only)

    /// Background green intensity for the faint CRT phosphor glow.
    static let crtBackgroundGlow: CGFloat = 0.02

    /// Blur radius for the green phosphor glow around intro text.
    static let crtGlowRadius: CGFloat = 15

    /// Spacing in points between CRT scanlines.
    static let crtScanlineSpacing: CGFloat = 3

    /// Opacity of CRT scanlines (0 = invisible, 1 = fully opaque).
    static let crtScanlineAlpha: CGFloat = 0.12

    /// Blur radius for the green phosphor glow around rain characters.
    static let crtRainGlowRadius: CGFloat = 18

    /// Trail characters dimmer than this are hidden, so trails
    /// fade cleanly into darkness instead of showing dark remnants.
    static let trailBrightnessCutoff: Double = 0.15

    /// Font size for the intro text (smaller than rain for a terminal feel).
    static let introFontSize: CGFloat = 18

    /// Padding from screen edges for intro text (terminal-style positioning).
    static let introPadding: CGFloat = 40

    /// Line height multiplier for intro text (relative to font size).
    static let introLineHeightMultiplier: CGFloat = 1.4

    // MARK: - Character set

    /// All 57 printable glyphs from the Matrix-Code.ttf custom font.
    /// Includes mirrored katakana, digits, and symbols from the films.
    static let matrixChars: [Character] = Array(
        "モエヤキオカ7ケサスz152ヨタワ4ネヌナ98ヒ0ホア3ウセ¦:\"꞊ミラリ╌ツテニハソ▪コシマムメー©*+<>|\u{E937}"
    )

    /// Returns a random character from the Matrix character set.
    /// - Precondition: `matrixChars` must not be empty.
    static func randomChar() -> Character {
        guard let char = matrixChars.randomElement() else {
            fatalError("matrixChars is empty — the character set must contain at least one glyph")
        }
        return char
    }
}
