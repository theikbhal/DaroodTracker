import Foundation
import AppKit

// Better icon - Star with crescent, modern design
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
    let padding = s * 0.05
    let rect = CGRect(x: padding, y: padding, width: s - padding*2, height: s - padding*2)
    
    // Background - rounded rectangle
    let cornerRadius = s * 0.22
    let bgPath = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    context.addPath(bgPath)
    context.clip()
    
    // Gradient background - deep navy to purple
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        CGColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0),
        CGColor(red: 0.2, green: 0.05, blue: 0.4, alpha: 1.0),
    ] as CFArray
    let locations: [CGFloat] = [0.0, 1.0]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])
    }
    
    // Draw crescent moon (Islamic symbol) - top right
    let moonCenter = CGPoint(x: s * 0.7, y: s * 0.7)
    let moonRadius = s * 0.15
    
    context.setFillColor(CGColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0))
    let moonPath = CGMutablePath()
    moonPath.addArc(center: moonCenter, radius: moonRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    context.addPath(moonPath)
    context.fillPath()
    
    // Cut out inner circle for crescent
    context.setFillColor(CGColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0))
    let innerMoonPath = CGMutablePath()
    innerMoonPath.addArc(center: CGPoint(x: moonCenter.x + moonRadius * 0.3, y: moonCenter.y), radius: moonRadius * 0.8, startAngle: 0, endAngle: .pi * 2, clockwise: false)
    context.addPath(innerMoonPath)
    context.fillPath()
    
    // Draw star - center left
    let starCenter = CGPoint(x: s * 0.35, y: s * 0.55)
    let starRadius = s * 0.18
    let innerRadius = s * 0.08
    
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
    
    // Draw beads (tasbih) - curved line
    context.setStrokeColor(CGColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 0.8))
    context.setLineWidth(s * 0.02)
    
    let beadCount = 11
    let beadRadius = s * 0.015
    for i in 0..<beadCount {
        let t = Double(i) / Double(beadCount - 1)
        let angle = .pi * 0.3 + t * .pi * 0.4
        let radius = s * 0.32
        let x = s * 0.5 + radius * cos(angle)
        let y = s * 0.35 + radius * sin(angle) * 0.5
        
        context.setFillColor(CGColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 0.9))
        let beadPath = CGMutablePath()
        beadPath.addArc(center: CGPoint(x: x, y: y), radius: beadRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        context.addPath(beadPath)
        context.fillPath()
    }
    
    // Draw + symbol - bottom center
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))
    context.setLineWidth(s * 0.03)
    context.setLineCap(.round)
    
    let plusCenter = CGPoint(x: s * 0.5, y: s * 0.25)
    let plusSize = s * 0.08
    
    // Horizontal line
    context.move(to: CGPoint(x: plusCenter.x - plusSize, y: plusCenter.y))
    context.addLine(to: CGPoint(x: plusCenter.x + plusSize, y: plusCenter.y))
    context.strokePath()
    
    // Vertical line
    context.move(to: CGPoint(x: plusCenter.x, y: plusCenter.y - plusSize))
    context.addLine(to: CGPoint(x: plusCenter.x, y: plusCenter.y + plusSize))
    context.strokePath()
    
    image.unlockFocus()
    return image
}

// Generate and save icons
let outputDir = "/Users/ikbhal/Desktop/mac_apps/DaroodTracker/Sources/Assets.xcassets/AppIcon.appiconset"

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
