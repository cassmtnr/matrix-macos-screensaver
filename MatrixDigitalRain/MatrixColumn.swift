import Foundation

final class MatrixColumn {
    let columnIndex: Int
    private let numRows: Int
    private var chars: [Character]
    private(set) var headY: Double
    private(set) var speed: Double
    private(set) var trailLength: Int
    private var remainingStartDelay: Double  // seconds

    init(columnIndex: Int, numRows: Int) {
        self.columnIndex = columnIndex
        self.numRows = numRows
        self.chars = (0..<numRows).map { _ in MatrixConfig.randomChar() }
        // Start columns above the screen so the screensaver begins with a black screen
        self.headY = -1
        self.speed = Double.random(in: MatrixConfig.minSpeed...MatrixConfig.maxSpeed)
        self.trailLength = Int.random(in: MatrixConfig.minTrailLength...MatrixConfig.maxTrailLength)
        self.remainingStartDelay = Double.random(in: 0..<Double(MatrixConfig.maxColumnStaggerFrames) / MatrixConfig.fps)
    }

    /// Update column state. `deltaTime` is seconds since last frame.
    func update(deltaTime: Double = 1.0 / MatrixConfig.fps) {
        let timeScale = deltaTime * MatrixConfig.fps  // 1.0 at target fps

        if remainingStartDelay > 0 {
            remainingStartDelay -= deltaTime
            return
        }

        headY += speed * timeScale

        // Reset when off screen
        if headY - Double(trailLength) > Double(numRows) {
            headY = Double.random(in: Double(-trailLength * 2)..<Double(-trailLength))
            speed = Double.random(in: MatrixConfig.minSpeed..<MatrixConfig.maxSpeed)
            trailLength = Int.random(in: MatrixConfig.minTrailLength..<MatrixConfig.maxTrailLength)
        }

        // Randomly mutate characters (glitch effect)
        for i in 0..<chars.count {
            if Double.random(in: 0..<1) < MatrixConfig.charChangeProb {
                chars[i] = MatrixConfig.randomChar()
            }
        }
    }

    func getBrightness(row: Int) -> Double {
        let distanceFromHead = headY - Double(row)
        if distanceFromHead < 0 || distanceFromHead > Double(trailLength) {
            return 0.0
        }
        if distanceFromHead < 1 {
            return 1.0  // Head is brightest (white)
        }
        return max(0, 1.0 - distanceFromHead / Double(trailLength))
    }

    func getChar(row: Int) -> Character {
        chars[row % chars.count]
    }
}
