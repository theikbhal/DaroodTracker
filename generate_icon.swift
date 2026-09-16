import Foundation
import AppKit

// Create icon sizes for macOS
let sizes: [(String, Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

func createIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let s = Double(size)
    
    // Background - rounded rectangle with gradient
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    let cornerRadius = s * 0.22
    
    // Draw background
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    context.addPath(path)
    context.clip()
    
    // Gradient background - deep blue to purple
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0),
        CGColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 1.0),
    ] as CFArray
    let locations: [CGFloat] = [0.0, 1.0]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])
    }
    
    // Draw star
    let starCenter = CGPoint(x: s * 0.5, y: s * 0.55)
    let starRadius = s * 0.25
    let innerRadius = s * 0.1
    
    context.setFillColor(CGColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0))
    
    let starPath = CGMutablePath()
    for i in 0..<10 {
        let angle = Double(i) * .pi / 5 - .pi / 2
        let radius = i % 2 == 0 ? starRadius : innerRadius
        let point = CGPoint(
            x: starCenter.x + radius * cos(angle),
            y: starCenter.y + radius * sin(angle)
        )
        if i == 0 {
            starPath.move(to: point)
        } else {
            starPath.addLine(to: point)
        }
    }
    starPath.closeSubpath()
    context.addPath(starPath)
    context.fillPath()
    
    // Draw crescent moon
    let moonCenter = CGPoint(x: s * 0.5, y: s * 0.55)
    let moonRadius = s * 0.3
    let moonOffset = s * 0.08
    
    context.setFillColor(CGColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0))
    
    let moonPath = CGMutablePath()
    moonPath.addArc(center: moonCenter, radius: moonRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    context.addPath(moonPath)
    context.fillPath()
    
    context.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0))
    let innerMoonPath = CGMutablePath()
    innerMoonPath.addArc(center: CGPoint(x: moonCenter.x + moonOffset, y: moonCenter.y), radius: moonRadius * 0.85, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    context.addPath(innerMoonPath)
    context.fillPath()
    
    // Draw hand silhouette
    let handCenter = CGPoint(x: s * 0.5, y: s * 0.3)
    let handWidth = s * 0.4
    let handHeight = s * 0.25
    
    context.setFillColor(CGColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 0.3))
    
    let palmRect = CGRect(
        x: handCenter.x - handWidth/2,
        y: handCenter.y - handHeight/2,
        width: handWidth,
        height: handHeight
    )
    let palmPath = CGPath(roundedRect: palmRect, cornerWidth: handWidth * 0.3, cornerHeight: handWidth * 0.3, transform: nil)
    context.addPath(palmPath)
    context.fillPath()
    
    let fingerWidth = handWidth * 0.15
    let fingerHeight = handHeight * 0.6
    let fingerSpacing = handWidth * 0.05
    
    for i in 0..<5 {
        let fingerX = palmRect.minX + (Double(i) * (fingerWidth + fingerSpacing))
        let fingerRect = CGRect(
            x: fingerX,
            y: palmRect.maxY - fingerHeight * 0.3,
            width: fingerWidth,
            height: fingerHeight
        )
        let fingerPath = CGPath(roundedRect: fingerRect, cornerWidth: fingerWidth * 0.4, cornerHeight: fingerWidth * 0.4, transform: nil)
        context.addPath(fingerPath)
        context.fillPath()
    }
    
    // Draw progress ring
    let ringCenter = CGPoint(x: s * 0.5, y: s * 0.55)
    let ringRadius = s * 0.38
    let ringWidth = s * 0.04
    
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3))
    context.setLineWidth(ringWidth)
    context.strokeEllipse(in: CGRect(
        x: ringCenter.x - ringRadius,
        y: ringCenter.y - ringRadius,
        width: ringRadius * 2,
        height: ringRadius * 2
    ))
    
    // Progress arc (75% complete)
    context.setStrokeColor(CGColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0))
    context.setLineWidth(ringWidth)
    
    let startAngle: CGFloat = .pi / 2
    let endAngle: CGFloat = .pi / 2 + .pi * 1.5
    context.addArc(center: ringCenter, radius: ringRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    context.strokePath()
    
    image.unlockFocus()
    return image
}

// Generate and save icons
let outputDir = "/Users/ikbhal/Desktop/mac_apps/DaroodTracker/Assets.xcassets/AppIcon.appiconset"

for (name, size) in sizes {
    let icon = createIcon(size: size)
    if let tiffData = icon.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        let url = URL(fileURLWithPath: "\(outputDir)/\(name).png")
        try? pngData.write(to: url)
        print("Created \(name).png (\(size)x\(size))")
    }
}

print("Icon generation complete!")
