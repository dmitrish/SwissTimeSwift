//
//  KnotUrushi.swift
//  SwissTimeSwift
//
//  Created by Shpinar Dmitri on 12/12/25.
//


//
//  KnotUrushi.swift
//  iosworldclock
//
//  Created by Shpinar Dmitri on 12/6/25.
//


import SwiftUI

struct KnotUrushi: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2 * 0.8
            
            ZStack {
                // Static content
                Canvas { context, size in
                    drawClockFace(context: context, center: center, radius: radius)
                    drawKnotPattern(context: context, center: center, radius: radius)
                    drawHourMarkers(context: context, center: center, radius: radius)
                    drawLogo(context: context, center: center, radius: radius)
                }
                
                // Animated content
                Canvas { context, size in
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: currentTime) % 12
                    let minute = calendar.component(.minute, from: currentTime)
                    let second = calendar.component(.second, from: currentTime)
                    
                    let hourAngle = Double(hour * 30 + minute) * 0.5
                    let minuteAngle = Double(minute * 6)
                    let secondAngle = Double(second * 6)
                    
                    drawClockHands(
                        context: context,
                        center: center,
                        radius: radius,
                        hourAngle: hourAngle,
                        minuteAngle: minuteAngle,
                        secondAngle: secondAngle
                    )
                    
                    drawCenterDot(context: context, center: center, radius: radius)
                }
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

// MARK: - Colors (Urushi lacquer inspired)

private let urushiRed = Color(red: 0.55, green: 0.0, blue: 0.0)      // Deep red
private let urushiBlack = Color(red: 0.1, green: 0.1, blue: 0.1)     // Black lacquer
private let urushiGold = Color(red: 0.85, green: 0.65, blue: 0.13)   // Gold accent
private let urushiCream = Color(red: 0.95, green: 0.94, blue: 0.9)   // Cream/ivory

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Outer border (gold bezel)
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(urushiGold), lineWidth: 8)
    
    // Main dial (urushi lacquer red)
    let dialCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.95,
        y: center.y - radius * 0.95,
        width: radius * 1.9,
        height: radius * 1.9
    ))
    context.fill(dialCircle, with: .color(urushiRed))
    
    // Inner decorative circle
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.7,
        y: center.y - radius * 0.7,
        width: radius * 1.4,
        height: radius * 1.4
    ))
    context.stroke(innerCircle, with: .color(urushiGold), lineWidth: 1)
}

private func drawKnotPattern(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw Celtic/Japanese inspired knot pattern
    // This creates an interwoven circular pattern characteristic of traditional Japanese design
    
    let knotRadius = radius * 0.4
    let knotCount = 8
    
    for i in 0..<knotCount {
        let angle1 = Double.pi * 2 * Double(i) / Double(knotCount)
        let angle2 = Double.pi * 2 * Double(i + 1) / Double(knotCount)
        
        let x1 = center.x + cos(angle1) * knotRadius
        let y1 = center.y + sin(angle1) * knotRadius
        let x2 = center.x + cos(angle2) * knotRadius
        let y2 = center.y + sin(angle2) * knotRadius
        
        // Create curved segments
        var path = Path()
        path.move(to: CGPoint(x: x1, y: y1))
        
        let controlAngle = (angle1 + angle2) / 2
        let controlRadius = knotRadius * 0.7
        let controlX = center.x + cos(controlAngle) * controlRadius
        let controlY = center.y + sin(controlAngle) * controlRadius
        
        path.addQuadCurve(
            to: CGPoint(x: x2, y: y2),
            control: CGPoint(x: controlX, y: controlY)
        )
        
        context.stroke(
            path,
            with: .color(urushiGold.opacity(0.5)),
            style: StrokeStyle(lineWidth: 3, lineCap: .round)
        )
    }
    
    // Draw interlocking circles
    for i in 0..<4 {
        let angle = Double.pi / 2 * Double(i)
        let circleX = center.x + cos(angle) * radius * 0.3
        let circleY = center.y + sin(angle) * radius * 0.3
        
        let smallCircle = Path(ellipseIn: CGRect(
            x: circleX - radius * 0.1,
            y: circleY - radius * 0.1,
            width: radius * 0.2,
            height: radius * 0.2
        ))
        
        context.stroke(
            smallCircle,
            with: .color(urushiGold.opacity(0.6)),
            lineWidth: 2
        )
    }
}

private func drawHourMarkers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw elegant hour markers with Japanese aesthetic
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i) - Double.pi / 2
        
        // Outer markers (larger for 12, 3, 6, 9)
        let isCardinal = i % 3 == 0
        let markerLength = isCardinal ? radius * 0.12 : radius * 0.08
        let markerWidth: CGFloat = isCardinal ? 3 : 2
        
        let outerX = center.x + cos(angle) * radius * 0.85
        let outerY = center.y + sin(angle) * radius * 0.85
        let innerX = center.x + cos(angle) * (radius * 0.85 - markerLength)
        let innerY = center.y + sin(angle) * (radius * 0.85 - markerLength)
        
        var markerPath = Path()
        markerPath.move(to: CGPoint(x: outerX, y: outerY))
        markerPath.addLine(to: CGPoint(x: innerX, y: innerY))
        
        context.stroke(
            markerPath,
            with: .color(urushiCream),
            style: StrokeStyle(lineWidth: markerWidth, lineCap: .round)
        )
        
        // Add gold accent to cardinal markers
        if isCardinal {
            let dotX = center.x + cos(angle) * radius * 0.9
            let dotY = center.y + sin(angle) * radius * 0.9
            
            let dot = Path(ellipseIn: CGRect(
                x: dotX - 3,
                y: dotY - 3,
                width: 6,
                height: 6
            ))
            context.fill(dot, with: .color(urushiGold))
        }
    }
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw Japanese-style branding
    let logoText = Text("結")  // "Knot" in Japanese
        .font(.system(size: radius * 0.15, weight: .bold))
        .foregroundColor(urushiCream)
    
    context.draw(logoText, at: CGPoint(x: center.x, y: center.y - radius * 0.5))
    
    // Subtitle
    let subtitleText = Text("URUSHI")
        .font(.system(size: radius * 0.08, weight: .medium))
        .foregroundColor(urushiGold)
    
    context.draw(subtitleText, at: CGPoint(x: center.x, y: center.y - radius * 0.35))
    
    // Date window at 6 o'clock position
    let calendar = Calendar.current
    let day = calendar.component(.day, from: Date())
    
    let dateX = center.x
    let dateY = center.y + radius * 0.5
    
    // Date window background
    let dateWindow = Path(roundedRect: CGRect(
        x: dateX - radius * 0.12,
        y: dateY - radius * 0.08,
        width: radius * 0.24,
        height: radius * 0.16
    ), cornerRadius: 3)
    
    context.fill(dateWindow, with: .color(urushiCream))
    context.stroke(dateWindow, with: .color(urushiGold), lineWidth: 1)
    
    // Date text
    let dateText = Text("\(day)")
        .font(.system(size: radius * 0.1, weight: .bold))
        .foregroundColor(urushiBlack)
    
    context.draw(dateText, at: CGPoint(x: dateX, y: dateY))
}

private func drawClockHands(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    hourAngle: Double,
    minuteAngle: Double,
    secondAngle: Double
) {
    // Hour hand (katana sword style)
    var hourContext = context
    hourContext.translateBy(x: center.x, y: center.y)
    hourContext.rotate(by: .degrees(hourAngle))
    
    var hourPath = Path()
    hourPath.move(to: CGPoint(x: 0, y: -radius * 0.45))
    hourPath.addLine(to: CGPoint(x: radius * 0.03, y: -radius * 0.35))
    hourPath.addLine(to: CGPoint(x: radius * 0.02, y: radius * 0.1))
    hourPath.addLine(to: CGPoint(x: -radius * 0.02, y: radius * 0.1))
    hourPath.addLine(to: CGPoint(x: -radius * 0.03, y: -radius * 0.35))
    hourPath.closeSubpath()
    
    hourContext.fill(hourPath, with: .color(urushiCream))
    hourContext.stroke(hourPath, with: .color(urushiGold), lineWidth: 1)
    
    // Minute hand (katana sword style, longer)
    var minuteContext = context
    minuteContext.translateBy(x: center.x, y: center.y)
    minuteContext.rotate(by: .degrees(minuteAngle))
    
    var minutePath = Path()
    minutePath.move(to: CGPoint(x: 0, y: -radius * 0.65))
    minutePath.addLine(to: CGPoint(x: radius * 0.025, y: -radius * 0.5))
    minutePath.addLine(to: CGPoint(x: radius * 0.015, y: radius * 0.1))
    minutePath.addLine(to: CGPoint(x: -radius * 0.015, y: radius * 0.1))
    minutePath.addLine(to: CGPoint(x: -radius * 0.025, y: -radius * 0.5))
    minutePath.closeSubpath()
    
    minuteContext.fill(minutePath, with: .color(urushiCream))
    minuteContext.stroke(minutePath, with: .color(urushiGold), lineWidth: 1)
    
    // Second hand (thin, elegant)
    var secondContext = context
    secondContext.translateBy(x: center.x, y: center.y)
    secondContext.rotate(by: .degrees(secondAngle))
    
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.15))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.75))
    
    secondContext.stroke(
        secondPath,
        with: .color(urushiGold),
        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
    )
    
    // Second hand counterweight
    let counterweight = Path(ellipseIn: CGRect(
        x: -radius * 0.02,
        y: radius * 0.1,
        width: radius * 0.04,
        height: radius * 0.08
    ))
    secondContext.fill(counterweight, with: .color(urushiGold))
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Outer ring
    let outerRing = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.04,
        y: center.y - radius * 0.04,
        width: radius * 0.08,
        height: radius * 0.08
    ))
    context.fill(outerRing, with: .color(urushiGold))
    
    // Inner dot
    let innerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.02,
        y: center.y - radius * 0.02,
        width: radius * 0.04,
        height: radius * 0.04
    ))
    context.fill(innerDot, with: .color(urushiRed))
}

// MARK: - Preview

struct KnotUrushi_Previews: PreviewProvider {
    static var previews: some View {
        KnotUrushi()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
