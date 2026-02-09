import ScreenSaver
import AVFoundation
import AVKit

class MatrixSaverView: ScreenSaverView {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var loopObserver: NSObjectProtocol?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setupPlayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }

    private func setupPlayer() {
        // Find the video file in the bundle's Resources folder
        let bundle = Bundle(for: type(of: self))
        guard let videoURL = bundle.url(forResource: "matrix_screensaver", withExtension: "mov") else {
            NSLog("MatrixSaver: Could not find matrix_screensaver.mov in bundle resources")
            return
        }

        NSLog("MatrixSaver: Loading video from \(videoURL.path)")

        // Create player
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player?.isMuted = true

        // Create player layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = .resizeAspectFill

        // Add layer to view
        wantsLayer = true
        if let playerLayer = playerLayer {
            layer?.addSublayer(playerLayer)
        }

        // Set up looping
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }

    override func startAnimation() {
        super.startAnimation()
        player?.play()
    }

    override func stopAnimation() {
        super.stopAnimation()
        player?.pause()
    }

    override func layout() {
        super.layout()
        playerLayer?.frame = bounds
    }

    override func draw(_ rect: NSRect) {
        // Draw black background in case video hasn't loaded yet
        NSColor.black.setFill()
        rect.fill()
    }

    override var hasConfigureSheet: Bool {
        return false
    }

    override var configureSheet: NSWindow? {
        return nil
    }

    deinit {
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
