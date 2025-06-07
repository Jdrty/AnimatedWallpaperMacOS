import Cocoa
import AVFoundation

class D {
    var w: [NSWindow] = []
    func r() {
        let u = URL(fileURLWithPath: "/Users/student/Desktop/Mac/customWP/wallpaper.mp4")
        for s in NSScreen.screens {
            let win = NSWindow(
                contentRect: s.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: s
            )
            win.level = .init(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
            win.isOpaque = false
            win.backgroundColor = .clear
            win.ignoresMouseEvents = true
            win.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .transient]

            let v = NSView(frame: s.frame)
            v.wantsLayer = true

            let p = AVPlayer(url: u)
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: p.currentItem, queue: .main) { _ in
                p.seek(to: .zero)
                p.play()
            }

            let l = AVPlayerLayer(player: p)
            l.frame = s.frame
            l.videoGravity = .resizeAspectFill
            v.layer?.addSublayer(l)
            win.contentView = v
            p.play()
            win.makeKeyAndOrderFront(nil)
            w.append(win)
        }
    }
}