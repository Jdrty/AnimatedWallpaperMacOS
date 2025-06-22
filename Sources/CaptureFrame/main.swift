import Foundation      // URL, Data
import AVFoundation    // AVAssetImageGenerator
import AppKit          // NSBitmapImageRep

// Expand "~" in a path.
extension String { var tildeExpanded: String { (self as NSString).expandingTildeInPath } }

func die(_ msg: String) -> Never {
    FileHandle.standardError.write(Data(msg.utf8))
    exit(1)
}

let argv = CommandLine.arguments
guard argv.count >= 2 else {
    die("usage: CaptureFrame <video> [jpgOut] [seconds]\n")
}

let videoURL = URL(fileURLWithPath: argv[1].tildeExpanded)
let jpgURL   = argv.count >= 3
    ? URL(fileURLWithPath: argv[2].tildeExpanded)
    : URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("frame.jpg")
let seconds  = argv.count >= 4 ? Double(argv[3]) ?? 10.0 : 10.0

let asset = AVURLAsset(url: videoURL)
let gen   = AVAssetImageGenerator(asset: asset)
gen.appliesPreferredTrackTransform = true
let time  = CMTime(seconds: seconds, preferredTimescale: 600)

guard let cg = try? gen.copyCGImage(at: time, actualTime: nil) else {
    die("capture failed at \(seconds)s\n")
}

let rep  = NSBitmapImageRep(cgImage: cg)
let props: [NSBitmapImageRep.PropertyKey: Any] = [.compressionFactor: 0.9]
guard let data = rep.representation(using: .jpeg, properties: props) else {
    die("JPEG encode failed\n")
}

do {
    try data.write(to: jpgURL, options: .atomic)
    print(jpgURL.path)          // let caller read path from stdout
} catch {
    die("write failed: \(error.localizedDescription)\n")
}
