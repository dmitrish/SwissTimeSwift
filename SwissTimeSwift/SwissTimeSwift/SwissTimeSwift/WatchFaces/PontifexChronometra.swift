//
//  PontifexChronometra.swift
//  SwissTimeSwift
//
//  Created by Shpinar Dmitri on 12/12/25.
//


import SwiftUI

struct PontifexChronometra: View {
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
                    drawHourMarkers(context: context, center: center, radius: radius)
                    drawGuilloche(context: context, center: center, radius: radius)
                    drawDateWindow(context: context, center: center, radius: radius)
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

// MARK: - Colors

private let clockFaceColor = Color(red: 0.117, green: 0.173, blue: 0.290)    // Deep blue dial
private let clockBorderColor = Color(red: 0.831, green: 0.686, blue: 0.216)  // Gold border
private let handColor = Color(red: 0.878, green: 0.878, blue: 0.878)         // Silver hands
private let secondHandColor = Color(red: 0.831, green: 0.686, blue: 0.216)   // Gold second hand
private let markersColor = Color(red: 0.878, green: 0.878, blue: 0.878)      // Silver markers
private let accentColor = Color(red: 0.831, green: 0.686, blue: 0.216)       // Gold accent
private let guillcheColor = Color(red: 0.164, green: 0.235, blue: 0.353)     // Subtle guilloche

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Outer border (gold)
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: radius * 0.03)
    
    // Main dial (deep blue)
    let dialCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.97,
        y: center.y - radius * 0.97,
        width: radius * 1.94,
        height: radius * 1.94
    ))
    context.fill(dialCircle, with: .color(clockFaceColor))
    
    // Subtle inner ring
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.9,
        y: center.y - radius * 0.9,
        width: radius * 1.8,
        height: radius * 1.8
    ))
    context.stroke(innerCircle, with: .color(clockBorderColor), lineWidth: radius * 0.005)
}


private func drawHourMarkers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i) - Double.pi / 2
        let markerRadius = radius * 0.85
        
        let markerX = center.x + CGFloat(cos(angle)) * markerRadius
        let markerY = center.y + CGFloat(sin(angle)) * markerRadius
        
        if i % 3 == 0 {
            // Double marker for 12, 3, 6, 9 (cardinal positions)
            var path = Path()
            let perpAngle = angle + Double.pi / 2
            
            path.move(to: CGPoint(
                x: markerX - CGFloat(cos(perpAngle)) * radius * 0.04,
                y: markerY - CGFloat(sin(perpAngle)) * radius * 0.04
            ))
            path.addLine(to: CGPoint(
                x: markerX + CGFloat(cos(perpAngle)) * radius * 0.04,
                y: markerY + CGFloat(sin(perpAngle)) * radius * 0.04
            ))
            
            context.stroke(
                path,
                with: .color(markersColor),
                style: StrokeStyle(lineWidth: radius * 0.02, lineCap: .round)
            )
        } else {
            // Teardrop markers for other hours (distinctive Parmigiani style)
            var teardropPath = Path()
            
            let tipX = markerX + CGFloat(cos(angle)) * radius * 0.03
            let tipY = markerY + CGFloat(sin(angle)) * radius * 0.03
            
            teardropPath.move(to: CGPoint(x: tipX, y: tipY))
            
            // Create teardrop shape pointing toward center
            let angleToCenter = atan2(center.y - markerY, center.x - markerX)
            
            let controlX1 = markerX + CGFloat(cos(Double(angleToCenter) + 0.5)) * radius * 0.02
            let controlY1 = markerY + CGFloat(sin(Double(angleToCenter) + 0.5)) * radius * 0.02
            let controlX2 = markerX + CGFloat(cos(Double(angleToCenter) - 0.5)) * radius * 0.02
            let controlY2 = markerY + CGFloat(sin(Double(angleToCenter) - 0.5)) * radius * 0.02
            
            teardropPath.addQuadCurve(
                to: CGPoint(x: markerX, y: markerY),
                control: CGPoint(x: controlX1, y: controlY1)
            )
            
            teardropPath.addQuadCurve(
                to: CGPoint(x: tipX, y: tipY),
                control: CGPoint(x: controlX2, y: controlY2)
            )
            
            teardropPath.closeSubpath()
            context.fill(teardropPath, with: .color(markersColor))
        }
    }
}

private func drawGuilloche(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let patternRadius = radius * 0.7
    
    // Draw wave pattern (simplified guilloche)
    for angle in stride(from: 0, to: 360, by: 5) {
        let radians = Double(angle) * Double.pi / 180
        
        // Create a wave effect
        let waveAmplitude = radius * 0.02
        let waveFrequency = 8.0
        
        var path = Path()
        let startX = center.x + CGFloat(cos(radians)) * (radius * 0.2)
        let startY = center.y + CGFloat(sin(radians)) * (radius * 0.2)
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        for i in 0...100 {
            let t = Double(i) / 100.0
            let distance = radius * 0.2 + CGFloat(t) * (patternRadius - radius * 0.2)
            let waveOffset = CGFloat(sin(t * waveFrequency * Double.pi)) * waveAmplitude
            
            let x = center.x + CGFloat(cos(radians)) * distance + CGFloat(cos(radians + Double.pi / 2)) * waveOffset
            let y = center.y + CGFloat(sin(radians)) * distance + CGFloat(sin(radians + Double.pi / 2)) * waveOffset
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        context.stroke(
            path,
            with: .color(guillcheColor),
            style: StrokeStyle(lineWidth: 0.5)
        )
    }
}

private func drawDateWindow(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let dateWindowX = center.x + radius * 0.6
    let dateWindowY = center.y
    let dateWindowWidth = radius * 0.15
    let dateWindowHeight = radius * 0.1
    
    // Date window background
    let windowRect = CGRect(
        x: dateWindowX - dateWindowWidth / 2,
        y: dateWindowY - dateWindowHeight / 2,
        width: dateWindowWidth,
        height: dateWindowHeight
    )
    
    context.fill(
        Path(windowRect),
        with: .color(Color(red: 0.039, green: 0.082, blue: 0.145))
    )
    
    // Date window border
    context.stroke(
        Path(windowRect),
        with: .color(accentColor),
        lineWidth: 1
    )
    
    // Date text
    let calendar = Calendar.current
    let day = calendar.component(.day, from: Date())
    
    let dateText = Text("\(day)")
        .font(.system(size: radius * 0.06, weight: .semibold))
        .foregroundColor(markersColor)
    
    context.draw(dateText, at: CGPoint(x: dateWindowX, y: dateWindowY))
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Brand name
    let brandText = Text("PONTIFEX")
        .font(.system(size: radius * 0.07, weight: .medium))
        .foregroundColor(markersColor)
    
    context.draw(brandText, at: CGPoint(x: center.x, y: center.y - radius * 0.25))
    
    // Collection name
    let collectionText = Text("CHRONOMETRA")
        .font(.system(size: radius * 0.05, weight: .regular))
        .foregroundColor(markersColor)
    
    context.draw(collectionText, at: CGPoint(x: center.x, y: center.y - radius * 0.15))
    
    // Swiss Made text
    let swissText = Text("SWISS MADE")
        .font(.system(size: radius * 0.04, weight: .light))
        .foregroundColor(markersColor)
    
    context.draw(swissText, at: CGPoint(x: center.x, y: center.y + radius * 0.5))
}

private func drawClockHands(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    hourAngle: Double,
    minuteAngle: Double,
    secondAngle: Double
) {
    // Hour hand - Delta-shaped (Parmigiani style)
    var hourContext = context
    hourContext.translateBy(x: center.x, y: center.y)
    hourContext.rotate(by: .degrees(hourAngle))
    
    var hourPath = Path()
    hourPath.move(to: CGPoint(x: 0, y: -radius * 0.45))              // Tip
    hourPath.addLine(to: CGPoint(x: radius * 0.04, y: -radius * 0.2)) // Right shoulder
    hourPath.addLine(to: CGPoint(x: radius * 0.015, y: 0))            // Right base
    hourPath.addLine(to: CGPoint(x: -radius * 0.015, y: 0))           // Left base
    hourPath.addLine(to: CGPoint(x: -radius * 0.04, y: -radius * 0.2)) // Left shoulder
    hourPath.closeSubpath()
    
    hourContext.fill(hourPath, with: .color(handColor))
    
    // Minute hand - Delta-shaped
    var minuteContext = context
    minuteContext.translateBy(x: center.x, y: center.y)
    minuteContext.rotate(by: .degrees(minuteAngle))
    
    var minutePath = Path()
    minutePath.move(to: CGPoint(x: 0, y: -radius * 0.65))              // Tip
    minutePath.addLine(to: CGPoint(x: radius * 0.03, y: -radius * 0.3)) // Right shoulder
    minutePath.addLine(to: CGPoint(x: radius * 0.01, y: 0))             // Right base
    minutePath.addLine(to: CGPoint(x: -radius * 0.01, y: 0))            // Left base
    minutePath.addLine(to: CGPoint(x: -radius * 0.03, y: -radius * 0.3)) // Left shoulder
    minutePath.closeSubpath()
    
    minuteContext.fill(minutePath, with: .color(handColor))
    
    // Second hand with oval counterbalance
    var secondContext = context
    secondContext.translateBy(x: center.x, y: center.y)
    secondContext.rotate(by: .degrees(secondAngle))
    
    // Main hand
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.2))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.75))
    
    secondContext.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
    )
    
    // Oval counterbalance
    var ovalPath = Path()
    let ovalWidth = radius * 0.05
    let ovalHeight = radius * 0.1
    
    ovalPath.move(to: CGPoint(x: 0, y: ovalHeight))
    ovalPath.addQuadCurve(
        to: CGPoint(x: ovalWidth, y: ovalHeight / 2),
        control: CGPoint(x: ovalWidth, y: ovalHeight)
    )
    ovalPath.addQuadCurve(
        to: CGPoint(x: 0, y: 0),
        control: CGPoint(x: ovalWidth, y: 0)
    )
    ovalPath.addQuadCurve(
        to: CGPoint(x: -ovalWidth, y: ovalHeight / 2),
        control: CGPoint(x: -ovalWidth, y: 0)
    )
    ovalPath.addQuadCurve(
        to: CGPoint(x: 0, y: ovalHeight),
        control: CGPoint(x: -ovalWidth, y: ovalHeight)
    )
    ovalPath.closeSubpath()
    
    secondContext.fill(ovalPath, with: .color(secondHandColor))
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.02,
        y: center.y - radius * 0.02,
        width: radius * 0.04,
        height: radius * 0.04
    ))
    context.fill(centerDot, with: .color(accentColor))
}

// MARK: - Preview

struct PontifexChronometra_Previews: PreviewProvider {
    static var previews: some View {
        PontifexChronometra()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
