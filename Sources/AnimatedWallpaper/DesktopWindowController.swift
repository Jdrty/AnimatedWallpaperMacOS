import Cocoa
import AVFoundation

final class DesktopWindowController {

    private var wallpaperWindows: [NSWindow] = []
    private var spaceObserver: Any?
    private var posterFile: URL?

    func reload() {
        closeExisting()
        createForAllScreens()
    }

    deinit {
        if let t = spaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(t)
        }
        DistributedNotificationCenter.default().removeObserver(self)
        closeExisting()
    }

    private func closeExisting() {
        wallpaperWindows.forEach { $0.close() }
        wallpaperWindows.removeAll()
    }

    private func makePoster(with video: URL) -> URL? {
        let exeURL = URL(fileURLWithPath: CommandLine.arguments[0])
            .deletingLastPathComponent()
            .appendingPathComponent("CaptureFrame")
        guard FileManager.default.isExecutableFile(atPath: exeURL.path) else { return nil }

        let process = Process()
        process.executableURL = exeURL
        let outPath = "/tmp/animated-poster.jpg"
        process.arguments = [video.path, outPath, "10"]
        let pipe = Pipe()
        process.standardOutput = pipe
        try? process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0,
              FileManager.default.fileExists(atPath: outPath) else { return nil }
        return URL(fileURLWithPath: outPath)
    }

    private func applyPoster(_ file: URL) {
        for screen in NSScreen.screens {
            try? NSWorkspace.shared.setDesktopImageURL(file, for: screen, options: [:])
        }
    }

    private func createForAllScreens() {
        let videoURL = URL(fileURLWithPath: "/Users/student/Desktop/Mac/customWP/wallpaper.mp4")
        if let poster = makePoster(with: videoURL) {
            posterFile = poster
            applyPoster(poster)
        }

        for screen in NSScreen.screens {
            let win = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )
            win.level = .init(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
            win.isOpaque = false
            win.backgroundColor = .clear
            win.ignoresMouseEvents = true
            win.collectionBehavior = [.stationary, .canJoinAllSpaces, .ignoresCycle]

            let host = NSView(frame: screen.frame)
            host.wantsLayer = true

            let player = AVPlayer(url: videoURL)
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero); player.play()
            }

            let layer = AVPlayerLayer(player: player)
            layer.frame = screen.frame
            layer.videoGravity = .resizeAspectFill
            host.layer?.addSublayer(layer)

            win.contentView = host
            win.orderBack(nil)
            win.makeKeyAndOrderFront(nil)

            player.play()
            wallpaperWindows.append(win)
        }

        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(missionControlDidExit),
            name: NSNotification.Name("com.apple.MissionControl.exit"),
            object: nil
        )

        spaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, let file = self.posterFile else { return }
            self.applyPoster(file)
            self.restoreLevelsAndPlayback()
        }
    }

    @objc private func missionControlDidExit() {
        restoreLevelsAndPlayback()
    }

    private func restoreLevelsAndPlayback() {
        let desired = Int(CGWindowLevelForKey(.desktopWindow))
        for win in wallpaperWindows {
            if win.level.rawValue != desired {
                win.level = .init(rawValue: desired)
            }
            if let host = win.contentView,
               let layer = host.layer?.sublayers?.first as? AVPlayerLayer,
               let player = layer.player,
               player.rate == 0 {
                player.play()
            }
        }
    }
}
