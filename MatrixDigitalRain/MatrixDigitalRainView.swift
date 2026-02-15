import ScreenSaver
import CoreText

/// The main screensaver view. Orchestrates the intro sequence and the
/// falling Matrix digital rain animation.
///
/// ## Architecture
/// - `IntroSequence` handles the "Wake up, Neo..." typing animation
/// - `MatrixColumn` handles individual falling character columns
/// - `MatrixConfig` holds all tunable constants
///
/// The view's `animateOneFrame()` is called by the ScreenSaver framework.
/// During the intro, it delegates to `IntroSequence`. Once the intro
/// completes, it updates all columns using real elapsed time (delta-time)
/// for consistent speed regardless of frame rate.
@objc(MatrixDigitalRainView)
class MatrixDigitalRainView: ScreenSaverView {

    // MARK: - Properties

    private var columns: [MatrixColumn] = []
    private var numRows = 0
    private var lastBoundsSize: NSSize = .zero

    /// The intro sequence that plays before the rain starts.
    private var intro = IntroSequence()

    /// Tracks when the last frame was drawn, for delta-time calculation.
    private var lastFrameTime: Date?

    // MARK: - Cached rendering resources

    private var ctFont: CTFont?
    private var glyphCache: [Character: CGGlyph] = [:]
    private static var fontRegistered = false
    private let colorSpace = CGColorSpaceCreateDeviceRGB()

    /// Pre-computed green colors at 256 brightness levels.
    /// Indexed by `Int(brightness * 255)` during drawing to avoid
    /// creating a new `CGColor` for every visible cell on every frame.
    private var greenPalette: [CGColor] = []

    /// Green glow color for the phosphor bleed effect on rain characters.
    private lazy var rainGlowColor: CGColor = {
        CGColor(colorSpace: colorSpace, components: [0, 0.5, 0, 0.6])
            ?? CGColor(red: 0, green: 0.5, blue: 0, alpha: 0.6)
    }()

    // MARK: - Initialization

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
        Self.registerMatrixFont()

        let font = NSFont(name: "Matrix-Code", size: MatrixConfig.fontSize)
            ?? NSFont.monospacedSystemFont(ofSize: MatrixConfig.fontSize, weight: .medium)
        ctFont = font as CTFont
        buildGlyphCache()
        buildGreenPalette()
    }

    // MARK: - Font registration

    /// Registers the custom Matrix-Code.ttf font for use in this process.
    /// Called once and guarded by a static flag.
    private static func registerMatrixFont() {
        guard !fontRegistered else { return }
        fontRegistered = true

        let bundle = Bundle(for: MatrixDigitalRainView.self)
        guard let fontURL = bundle.url(forResource: "Matrix-Code", withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }

    /// Pre-maps each Matrix character to its glyph ID for fast rendering.
    private func buildGlyphCache() {
        guard let font = ctFont else { return }
        for char in MatrixConfig.matrixChars {
            var unichars = Array(String(char).utf16)
            var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
            CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
            glyphCache[char] = glyphs[0]
        }
    }

    /// Pre-computes 256 green CGColor values so the draw loop
    /// can index into the palette instead of allocating per-frame.
    private func buildGreenPalette() {
        greenPalette = (0...255).map { level in
            let green = CGFloat(level) / 255.0
            return CGColor(colorSpace: colorSpace, components: [0, green, 0, 1])
                ?? CGColor(red: 0, green: green, blue: 0, alpha: 1)
        }
    }

    // MARK: - Column layout

    /// Creates columns to fill the current bounds. Called when the view
    /// first appears or when its size changes (e.g., multi-display).
    private func initializeColumns() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        lastBoundsSize = bounds.size
        let columnCount = max(1, Int(bounds.width / MatrixConfig.columnWidth))
        let visibleRows = Int(bounds.height / MatrixConfig.fontSize)
        numRows = max(1, visibleRows + MatrixConfig.offScreenRowBuffer)
        columns = (0..<columnCount).map { MatrixColumn(columnIndex: $0, numRows: numRows) }
    }

    private func initializeIfNeeded() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        if columns.isEmpty || bounds.size != lastBoundsSize {
            initializeColumns()
        }
    }

    // MARK: - ScreenSaverView lifecycle

    override func startAnimation() {
        super.startAnimation()
        intro.reset()
        lastFrameTime = nil
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

    // MARK: - Animation

    override func animateOneFrame() {
        initializeIfNeeded()

        // Calculate real elapsed time for frame-rate-independent animation
        let now = Date()
        let deltaTime = lastFrameTime.map { now.timeIntervalSince($0) }
            ?? (1.0 / MatrixConfig.fps)
        lastFrameTime = now

        if !intro.isComplete {
            intro.update()
        } else {
            for column in columns {
                column.update(deltaTime: deltaTime)
            }
        }

        needsDisplay = true
    }

    // MARK: - Drawing

    override func draw(_ rect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // Black background (always)
        context.setFillColor(NSColor.black.cgColor)
        context.fill(bounds)

        // During intro, delegate drawing and skip the rain
        if !intro.isComplete {
            intro.draw(in: context, bounds: bounds)
            return
        }

        // Draw the falling rain
        guard let font = ctFont, !columns.isEmpty else { return }

        let colWidth = MatrixConfig.columnWidth
        let fontSize = MatrixConfig.fontSize
        let boundsHeight = bounds.height

        // Phosphor glow — one blur pass for all characters via transparency layer
        context.saveGState()
        context.setShadow(offset: .zero, blur: MatrixConfig.crtRainGlowRadius, color: rainGlowColor)
        context.beginTransparencyLayer(auxiliaryInfo: nil)

        for column in columns {
            let baseX = CGFloat(column.columnIndex) * colWidth

            for row in 0..<numRows {
                let brightness = column.brightness(atRow: row)
                guard brightness >= MatrixConfig.trailBrightnessCutoff else { continue }

                let char = column.character(atRow: row)
                guard var glyph = glyphCache[char] else { continue }

                let y = boundsHeight - CGFloat(row + 1) * fontSize

                // Head character (brightness ~1.0) is white; trail fades green → black
                let color: CGColor
                if brightness >= MatrixConfig.headBrightnessThreshold {
                    color = CGColor.white
                } else {
                    let paletteIndex = min(255, Int(brightness * 255))
                    color = greenPalette[paletteIndex]
                }

                context.setFillColor(color)
                var position = CGPoint(x: baseX, y: y)
                CTFontDrawGlyphs(font, &glyph, &position, 1, context)
            }
        }

        context.endTransparencyLayer()
        context.restoreGState()

        drawScanlines(in: context)
    }

    private func drawScanlines(in context: CGContext) {
        let spacing = MatrixConfig.crtScanlineSpacing
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: MatrixConfig.crtScanlineAlpha)
        var y: CGFloat = 0
        while y < bounds.height {
            context.addRect(CGRect(x: 0, y: y, width: bounds.width, height: 1))
            y += spacing
        }
        context.fillPath()
    }

    // MARK: - Configuration sheet (not used)

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
