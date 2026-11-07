// Run on macOS: swift Scripts/make_assets.swift
// Draws original vector artwork into Apple's layered tvOS icon assets.
import AppKit
import Foundation

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let assets = root.appending(path: "CurioTV/Assets.xcassets/App Icon & Top Shelf Image.brandassets")
let info: [String: Any] = ["author": "xcode", "version": 1]

func json(_ object: [String: Any], at url: URL) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]).write(to: url)
}

func draw(width: Int, height: Int, layer: String, to url: URL) throws {
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
        let context = NSGraphicsContext(bitmapImageRep: bitmap) else { return }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let w = CGFloat(width), h = CGFloat(height)
    let accent = NSColor(srgbRed: 0.99, green: 0.72, blue: 0.35, alpha: 1)
    if layer == "Back" || layer == "Shelf" {
        NSGradient(starting: NSColor(srgbRed: 0.035, green: 0.045, blue: 0.064, alpha: 1),
                   ending: NSColor(srgbRed: 0.09, green: 0.14, blue: 0.18, alpha: 1))?
            .draw(in: NSRect(x: 0, y: 0, width: w, height: h), angle: 15)
    }
    if layer == "Middle" || layer == "Shelf" {
        for factor in [0.55, 0.82, 1.1] {
            let diameter = h * factor
            let orbit = NSBezierPath(ovalIn: NSRect(x: w * 0.76 - diameter / 2, y: (h - diameter) / 2,
                                                  width: diameter, height: diameter))
            accent.withAlphaComponent(0.14).setStroke()
            orbit.lineWidth = max(1, h * 0.004)
            orbit.stroke()
        }
    }
    if layer == "Front" || layer == "Shelf" {
        let fontSize = h * (layer == "Shelf" ? 0.25 : 0.32)
        let word = "curio" as NSString
        let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize, weight: .semibold), .foregroundColor: NSColor.white]
        let size = word.size(withAttributes: attrs)
        let left = layer == "Shelf" ? w * 0.19 : (w - size.width) / 2 + h * 0.07
        let bottom = layer == "Shelf" ? h * 0.46 : (h - size.height) / 2
        word.draw(at: NSPoint(x: left, y: bottom), withAttributes: attrs)
        let cx = left - h * 0.11, cy = bottom + size.height * 0.5, radius = h * 0.08
        let sparkle = NSBezierPath()
        for index in 0..<8 {
            let angle = CGFloat(index) * .pi / 4
            let r = index.isMultiple(of: 2) ? radius : radius * 0.23
            let point = NSPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r)
            if index == 0 { sparkle.move(to: point) } else { sparkle.line(to: point) }
        }
        sparkle.close()
        accent.setFill()
        sparkle.fill()
        if layer == "Shelf" {
            ("Follow your curiosity." as NSString).draw(at: NSPoint(x: left, y: h * 0.32), withAttributes: [
                .font: NSFont.systemFont(ofSize: h * 0.055, weight: .regular),
                .foregroundColor: NSColor(srgbRed: 0.70, green: 0.74, blue: 0.80, alpha: 1)])
        }
    }
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    guard let png = bitmap.representation(using: .png, properties: [:]) else { return }
    try png.write(to: url)
}

for (name, width, height) in [("App Icon", 400, 240), ("App Icon - App Store", 1280, 768)] {
    let stack = assets.appending(path: "\(name).imagestack")
    try json(["info": info, "layers": ["Front", "Middle", "Back"].map { ["filename": "\($0).imagestacklayer"] }], at: stack.appending(path: "Contents.json"))
    for layer in ["Front", "Middle", "Back"] {
        let folder = stack.appending(path: "\(layer).imagestacklayer")
        let imageSet = folder.appending(path: "Content.imageset")
        try json(["info": info], at: folder.appending(path: "Contents.json"))
        let scales = name == "App Icon" ? [1, 2] : [1]
        try json(["info": info, "images": scales.map { ["filename": "image\($0).png", "idiom": "tv", "scale": "\($0)x"] }],
                 at: imageSet.appending(path: "Contents.json"))
        for scale in scales { try draw(width: width * scale, height: height * scale, layer: layer, to: imageSet.appending(path: "image\(scale).png")) }
    }
}
for (name, width) in [("Top Shelf Image", 1920), ("Top Shelf Image Wide", 2320)] {
    let folder = assets.appending(path: "\(name).imageset")
    try json(["info": info, "images": [1, 2].map { ["filename": "shelf\($0).png", "idiom": "tv", "scale": "\($0)x"] }], at: folder.appending(path: "Contents.json"))
    for scale in [1, 2] { try draw(width: width * scale, height: 720 * scale, layer: "Shelf", to: folder.appending(path: "shelf\(scale).png")) }
}
try json(["info": info, "assets": [
    ["filename": "App Icon.imagestack", "idiom": "tv", "role": "primary-app-icon", "size": "400x240"],
    ["filename": "App Icon - App Store.imagestack", "idiom": "tv", "role": "primary-app-icon", "size": "1280x768"],
    ["filename": "Top Shelf Image.imageset", "idiom": "tv", "role": "top-shelf-image", "size": "1920x720"],
    ["filename": "Top Shelf Image Wide.imageset", "idiom": "tv", "role": "top-shelf-image-wide", "size": "2320x720"]
]], at: assets.appending(path: "Contents.json"))
print("Created layered tvOS icons and Top Shelf artwork.")
