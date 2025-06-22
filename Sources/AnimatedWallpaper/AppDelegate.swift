import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: DesktopWindowController?

    func applicationDidFinishLaunching(_ n: Notification) {
        controller = DesktopWindowController()
        controller?.reload()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool {
        false
    }
}
