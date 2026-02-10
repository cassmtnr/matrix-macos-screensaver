import ScreenSaver
import CoreText

@objc(MatrixDigitalRainView)
class MatrixDigitalRainView: ScreenSaverView {
    private var columns: [MatrixColumn] = []
    private var numColumns: Int = 0
    private var numRows: Int = 0
    private var ctFont: CTFont!
    private var glyphCache: [Character: CGGlyph] = [:]
    private static var fontRegistered = false

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private static func registerMatrixFont() {
        guard !fontRegistered else { return }
        fontRegistered = true

        let bundle = Bundle(for: MatrixDigitalRainView.self)
        guard let fontURL = bundle.url(forResource: "Matrix-Code", withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }

    private func buildGlyphCache() {
        let font = ctFont!
        for char in MatrixConfig.matrixChars {
            var unichars = Array(String(char).utf16)
            var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
            CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
            glyphCache[char] = glyphs[0]
        }
    }

    private func setup() {
        animationTimeInterval = 1.0 / MatrixConfig.fps
        MatrixDigitalRainView.registerMatrixFont()
        let font = NSFont(name: "Matrix-Code", size: MatrixConfig.fontSize)
            ?? NSFont.monospacedSystemFont(ofSize: MatrixConfig.fontSize, weight: .medium)
        ctFont = font as CTFont
        buildGlyphCache()
    }

    private var lastBoundsSize: NSSize = .zero

    private func initializeColumns() {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        lastBoundsSize = bounds.size
        numColumns = max(1, Int(bounds.width / MatrixConfig.columnWidth))
        numRows = max(1, Int(bounds.height / MatrixConfig.fontSize) + 5)
        columns = (0..<numColumns).map { MatrixColumn(columnIndex: $0, numRows: numRows) }
    }

    private func initializeIfNeeded() {
        if bounds.width > 0 && bounds.height > 0 {
            if columns.isEmpty || bounds.size != lastBoundsSize {
                initializeColumns()
            }
        }
    }

    override func startAnimation() {
        super.startAnimation()
        initializeIfNeeded()
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        initializeIfNeeded()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        initializeIfNeeded()
    }

    override func animateOneFrame() {
        initializeIfNeeded()
        for column in columns { column.update() }
        needsDisplay = true
    }

    override func draw(_ rect: NSRect) {
        guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

        // Black background
        cgContext.setFillColor(NSColor.black.cgColor)
        cgContext.fill(bounds)

        if columns.isEmpty { initializeIfNeeded() }
        guard !columns.isEmpty else { return }

        let font = ctFont!
        let colWidth = MatrixConfig.columnWidth
        let fontSize = MatrixConfig.fontSize
        let boundsHeight = bounds.height
        let white = CGColor.white

        for column in columns {
            let baseX = CGFloat(column.columnIndex) * colWidth

            for row in 0..<numRows {
                let brightness = column.getBrightness(row: row)
                guard brightness > 0 else { continue }

                let char = column.getChar(row: row)
                guard var glyph = glyphCache[char] else { continue }

                let y = boundsHeight - CGFloat(row + 1) * fontSize

                let color: CGColor = brightness >= 0.95
                    ? white
                    : CGColor(
                        colorSpace: CGColorSpaceCreateDeviceRGB(),
                        components: [0, CGFloat(brightness), 0, 1]
                    )!

                cgContext.setFillColor(color)
                var position = CGPoint(x: baseX, y: y)
                CTFontDrawGlyphs(font, &glyph, &position, 1, cgContext)
            }
        }
    }

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
