import Foundation

/// A single column of falling Matrix characters.
///
/// Each column has a "head" that moves downward, leaving a trail of
/// glowing green characters that fade to black. When the trail moves
/// off-screen, the column resets to a random position above the screen
/// with new random speed and trail length.
final class MatrixColumn {

    // MARK: - Properties

    let columnIndex: Int
    private let numRows: Int
    private var chars: [Character]
    private(set) var headY: Double
    private(set) var speed: Double
    private(set) var trailLength: Int

    /// Seconds remaining before this column starts falling.
    /// Creates the staggered wave effect when rain begins.
    private var remainingStartDelay: Double

    // MARK: - Initialization

    init(columnIndex: Int, numRows: Int) {
        self.columnIndex = columnIndex
        self.numRows = numRows
        self.chars = (0..<numRows).map { _ in MatrixConfig.randomChar() }
        self.headY = -1  // Start above the screen
        self.speed = Double.random(in: MatrixConfig.minSpeed...MatrixConfig.maxSpeed)
        self.trailLength = Int.random(in: MatrixConfig.minTrailLength...MatrixConfig.maxTrailLength)
        self.remainingStartDelay = Double.random(in: 0...MatrixConfig.maxColumnStaggerDelay)
    }

    // MARK: - Update

    /// Advance the column by one time step.
    ///
    /// - Parameter deltaTime: Seconds elapsed since the last frame.
    ///   Defaults to one frame at the target FPS. Using real elapsed time
    ///   ensures consistent speed regardless of actual frame rate.
    func update(deltaTime: Double = 1.0 / MatrixConfig.fps) {
        // Wait for stagger delay before starting
        if remainingStartDelay > 0 {
            remainingStartDelay -= deltaTime
            return
        }

        // Scale movement by elapsed time (1.0 at target FPS)
        let timeScale = deltaTime * MatrixConfig.fps
        headY += speed * timeScale

        // Reset when the entire trail has moved off-screen
        if headY - Double(trailLength) > Double(numRows) {
            headY = Double.random(in: Double(-trailLength * 2)...Double(-trailLength))
            speed = Double.random(in: MatrixConfig.minSpeed...MatrixConfig.maxSpeed)
            trailLength = Int.random(in: MatrixConfig.minTrailLength...MatrixConfig.maxTrailLength)
        }

        // Randomly mutate characters to create the "glitch" effect
        for i in 0..<chars.count where Double.random(in: 0..<1) < MatrixConfig.perCellMutationChance {
            chars[i] = MatrixConfig.randomChar()
        }
    }

    // MARK: - Queries

    /// Returns the brightness (0.0–1.0) for the character at the given row.
    /// - 1.0 = the head (rendered as white)
    /// - 0.0–1.0 = trail characters (rendered as green, fading to black)
    /// - 0.0 = not visible
    func brightness(atRow row: Int) -> Double {
        let distanceFromHead = headY - Double(row)

        // Outside the visible trail
        guard distanceFromHead >= 0, distanceFromHead <= Double(trailLength) else {
            return 0.0
        }

        // The head itself is brightest
        if distanceFromHead < 1 {
            return 1.0
        }

        // Fade linearly along the trail
        return max(0, 1.0 - distanceFromHead / Double(trailLength))
    }

    /// Returns the character displayed at the given row.
    func character(atRow row: Int) -> Character {
        chars[row % chars.count]
    }
}
