import ScreenSaver

class MatrixDigitalRainView: ScreenSaverView {
    private var columns: [MatrixColumn] = []
    private var numColumns: Int = 0
    private var numRows: Int = 0
    private var matrixFont: NSFont!

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        animationTimeInterval = 1.0 / MatrixConfig.fps
        matrixFont = NSFont.monospacedSystemFont(ofSize: MatrixConfig.fontSize, weight: .medium)
    }

    private func initializeColumns() {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        numColumns = max(1, Int(bounds.width / MatrixConfig.columnWidth))
        numRows = max(1, Int(bounds.height / MatrixConfig.fontSize) + 5)
        columns = (0..<numColumns).map { MatrixColumn(columnIndex: $0, numRows: numRows) }
    }

    override func startAnimation() {
        super.startAnimation()
        if columns.isEmpty { initializeColumns() }
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    override func animateOneFrame() {
        if columns.isEmpty && bounds.width > 0 { initializeColumns() }
        for column in columns { column.update() }
        needsDisplay = true
    }

    override func draw(_ rect: NSRect) {
        // Black background
        NSColor.black.setFill()
        bounds.fill()

        guard !columns.isEmpty else { return }

        for column in columns {
            let x = CGFloat(column.columnIndex) * MatrixConfig.columnWidth

            for row in 0..<numRows {
                let brightness = column.getBrightness(row: row)
                guard brightness > 0 else { continue }

                let char = column.getChar(row: row)
                let y = bounds.height - CGFloat(row + 1) * MatrixConfig.fontSize

                let color: NSColor = brightness >= 0.95
                    ? .white
                    : NSColor(hue: MatrixConfig.hue / 360.0, saturation: 0.85, brightness: CGFloat(brightness), alpha: 1.0)

                let attributes: [NSAttributedString.Key: Any] = [.font: matrixFont!, .foregroundColor: color]
                String(char).draw(at: NSPoint(x: x, y: y), withAttributes: attributes)
            }
        }
    }

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
