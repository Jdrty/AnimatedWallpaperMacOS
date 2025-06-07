import Cocoa
class A: NSObject, NSApplicationDelegate {
    var d: D?
    func applicationDidFinishLaunching(_ n: Notification) {
        d = D()
        d?.r()
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }
}