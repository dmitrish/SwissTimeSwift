

import SwiftUI

struct VostokRussianMilitaryWatch: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2 * 0.8
            
            ZStack {
                // Static content
                Canvas { context, canvasSize in
                    drawClockFace(context: context, center: center, radius: radius)
                    drawBezel(context: context, center: center, radius: radius)
                    drawHourMarkers(context: context, center: center, radius: radius, currentTime: currentTime)
                    drawLogo(context: context, center: center, radius: radius)
                }
                
                // Animated content
                Canvas { context, canvasSize in
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

// MARK: - Colors (Vostok Russian Military Diver)

private let vostokBlueDialColor = Color(red: 0x0A/255.0, green: 0x38/255.0, blue: 0x75/255.0)
private let vostokCaseColor = Color(red: 0xD0/255.0, green: 0xD0/255.0, blue: 0xD0/255.0)
private let vostokBezelColor = Color(red: 0x1A/255.0, green: 0x4A/255.0, blue: 0x8C/255.0)
private let vostokBezelMarkerColor = Color.white
private let vostokHandsColor = Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0)
private let vostokSecondHandColor = Color(red: 0xFF/255.0, green: 0x3A/255.0, blue: 0x30/255.0)
private let vostokMarkersColor = Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0)
private let vostokLumeColor = Color(red: 0xB4/255.0, green: 0xFF/255.0, blue: 0xB4/255.0)
private let vostokDateColor = Color.white

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Outer stainless steel case
    let outerCase = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCase, with: .color(vostokCaseColor), lineWidth: radius * 0.05)
    
    // Main face with deep blue dial
    let mainFace = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.95,
        y: center.y - radius * 0.95,
        width: radius * 1.9,
        height: radius * 1.9
    ))
    context.fill(mainFace, with: .color(vostokBlueDialColor))
    
    // Radial gradient for depth
    let gradient = Gradient(colors: [
        vostokBlueDialColor.opacity(0.8),
        vostokBlueDialColor
    ])
    let radialGradient = GraphicsContext.Shading.radialGradient(
        gradient,
        center: center,
        startRadius: 0,
        endRadius: radius * 0.95
    )
    context.fill(mainFace, with: radialGradient)
}

private func drawBezel(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let bezelOuterRadius = radius * 0.95
    let bezelInnerRadius = radius * 0.8
    let bezelWidth = bezelOuterRadius - bezelInnerRadius
    
    // Draw bezel background
    let bezel = Path(ellipseIn: CGRect(
        x: center.x - bezelOuterRadius,
        y: center.y - bezelOuterRadius,
        width: bezelOuterRadius * 2,
        height: bezelOuterRadius * 2
    ))
    context.stroke(bezel, with: .color(vostokBezelColor), lineWidth: bezelWidth)
    
    // Draw bezel markers (60 minute/diving scale)
    for i in 0..<60 {
        let angle = Double.pi * 2 * Double(i) / 60 - Double.pi / 2
        
        let markerLength: CGFloat
        if i % 5 == 0 {
            markerLength = bezelWidth * 0.8
        } else {
            markerLength = bezelWidth * 0.4
        }
        
        let markerStart = bezelInnerRadius + bezelWidth * 0.1
        let markerEnd = markerStart + markerLength
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * markerStart,
            y: center.y + CGFloat(sin(angle)) * markerStart
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * markerEnd,
            y: center.y + CGFloat(sin(angle)) * markerEnd
        ))
        
        context.stroke(
            path,
            with: .color(vostokBezelMarkerColor),
            lineWidth: i % 5 == 0 ? 2.5 : 1.5
        )
        
        // Triangle marker at 12 o'clock
        if i == 0 {
            let triangleSize = bezelWidth * 0.5
            
            var trianglePath = Path()
            trianglePath.move(to: CGPoint(
                x: center.x,
                y: center.y - bezelOuterRadius + bezelWidth * 0.2
            ))
            trianglePath.addLine(to: CGPoint(
                x: center.x - triangleSize / 2,
                y: center.y - bezelOuterRadius + bezelWidth * 0.7
            ))
            trianglePath.addLine(to: CGPoint(
                x: center.x + triangleSize / 2,
                y: center.y - bezelOuterRadius + bezelWidth * 0.7
            ))
            trianglePath.closeSubpath()
            
            context.fill(trianglePath, with: .color(vostokBezelMarkerColor))
        }
    }
}

private func drawHourMarkers(context: GraphicsContext, center: CGPoint, radius: CGFloat, currentTime: Date) {
    let dialRadius = radius * 0.75
    
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i) - Double.pi / 2
        let markerX = center.x + CGFloat(cos(angle)) * dialRadius
        let markerY = center.y + CGFloat(sin(angle)) * dialRadius
        
        if i == 0 || i == 3 || i == 6 || i == 9 {
            // Skip 3 o'clock for date window
            if i == 3 { continue }
            
            // Larger markers at cardinal positions
            let markerWidth = radius * 0.06
            let markerHeight = radius * 0.12
            
            // Marker background
            context.fill(
                Path(CGRect(
                    x: markerX - markerWidth / 2,
                    y: markerY - markerHeight / 2,
                    width: markerWidth,
                    height: markerHeight
                )),
                with: .color(vostokMarkersColor)
            )
            
            // Lume effect
            context.fill(
                Path(CGRect(
                    x: markerX - markerWidth / 2 + 1,
                    y: markerY - markerHeight / 2 + 1,
                    width: markerWidth - 2,
                    height: markerHeight - 2
                )),
                with: .color(vostokLumeColor.opacity(0.7))
            )
            
            // Numeral
            let numeral: String
            switch i {
            case 0: numeral = "12"
            case 6: numeral = "6"
            case 9: numeral = "9"
            default: numeral = ""
            }
            
            context.draw(
                Text(numeral)
                    .font(.system(size: radius * 0.07, weight: .bold))
                    .foregroundColor(.black),
                at: CGPoint(x: markerX, y: markerY)
            )
        } else {
            // Standard dot markers
            let markerRadius = radius * 0.03
            
            // Marker background
            let marker = Path(ellipseIn: CGRect(
                x: markerX - markerRadius,
                y: markerY - markerRadius,
                width: markerRadius * 2,
                height: markerRadius * 2
            ))
            context.fill(marker, with: .color(vostokMarkersColor))
            
            // Lume effect
            let lume = Path(ellipseIn: CGRect(
                x: markerX - (markerRadius - 1),
                y: markerY - (markerRadius - 1),
                width: (markerRadius - 1) * 2,
                height: (markerRadius - 1) * 2
            ))
            context.fill(lume, with: .color(vostokLumeColor.opacity(0.7)))
        }
    }
    
    // Date window at 3 o'clock
    let dateX = center.x + dialRadius
    let dateY = center.y
    
    // Date window background
    let dateWindow = Path(CGRect(
        x: dateX - radius * 0.08,
        y: dateY - radius * 0.06,
        width: radius * 0.16,
        height: radius * 0.12
    ))
    context.fill(dateWindow, with: .color(vostokDateColor))
    context.stroke(dateWindow, with: .color(vostokCaseColor), lineWidth: 1)
    
    // Date text
    let calendar = Calendar.current
    let day = calendar.component(.day, from: currentTime)
    
    context.draw(
        Text("\(day)")
            .font(.system(size: radius * 0.08, weight: .bold))
            .foregroundColor(.black),
        at: CGPoint(x: dateX, y: dateY)
    )
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // "BOCTOK" text (Vostok in Cyrillic)
    context.draw(
        Text("BOCTOK")
            .font(.system(size: radius * 0.08, weight: .bold))
            .foregroundColor(vostokHandsColor),
        at: CGPoint(x: center.x, y: center.y - radius * 0.3)
    )
    
    // "АВТОМАТИК" text (Automatic in Russian)
    context.draw(
        Text("АВТОМАТИК")
            .font(.system(size: radius * 0.05))
            .foregroundColor(vostokHandsColor),
        at: CGPoint(x: center.x, y: center.y + radius * 0.4)
    )
    
    // "20ATM" water resistance
    context.draw(
        Text("20ATM")
            .font(.system(size: radius * 0.05))
            .foregroundColor(vostokHandsColor),
        at: CGPoint(x: center.x, y: center.y + radius * 0.2)
    )
}

private func drawClockHands(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    hourAngle: Double,
    minuteAngle: Double,
    secondAngle: Double
) {
    var context = context
    
    // Hour hand - arrow-shaped
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(hourAngle))
    
    var hourPath = Path()
    hourPath.move(to: CGPoint(x: 0, y: -radius * 0.4))
    hourPath.addLine(to: CGPoint(x: radius * 0.04, y: -radius * 0.3))
    hourPath.addLine(to: CGPoint(x: radius * 0.02, y: 0))
    hourPath.addLine(to: CGPoint(x: -radius * 0.02, y: 0))
    hourPath.addLine(to: CGPoint(x: -radius * 0.04, y: -radius * 0.3))
    hourPath.closeSubpath()
    
    context.fill(hourPath, with: .color(vostokHandsColor))
    
    // Lume on hour hand
    var hourLumePath = Path()
    hourLumePath.move(to: CGPoint(x: 0, y: -radius * 0.38))
    hourLumePath.addLine(to: CGPoint(x: radius * 0.03, y: -radius * 0.3))
    hourLumePath.addLine(to: CGPoint(x: radius * 0.015, y: -radius * 0.05))
    hourLumePath.addLine(to: CGPoint(x: -radius * 0.015, y: -radius * 0.05))
    hourLumePath.addLine(to: CGPoint(x: -radius * 0.03, y: -radius * 0.3))
    hourLumePath.closeSubpath()
    
    context.fill(hourLumePath, with: .color(vostokLumeColor.opacity(0.7)))
    
    context.rotate(by: .degrees(-hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand - straight with slight taper
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(minuteAngle))
    
    var minutePath = Path()
    minutePath.move(to: CGPoint(x: 0, y: -radius * 0.65))
    minutePath.addLine(to: CGPoint(x: radius * 0.025, y: -radius * 0.1))
    minutePath.addLine(to: CGPoint(x: radius * 0.015, y: 0))
    minutePath.addLine(to: CGPoint(x: -radius * 0.015, y: 0))
    minutePath.addLine(to: CGPoint(x: -radius * 0.025, y: -radius * 0.1))
    minutePath.closeSubpath()
    
    context.fill(minutePath, with: .color(vostokHandsColor))
    
    // Lume on minute hand
    var minuteLumePath = Path()
    minuteLumePath.move(to: CGPoint(x: 0, y: -radius * 0.63))
    minuteLumePath.addLine(to: CGPoint(x: radius * 0.02, y: -radius * 0.1))
    minuteLumePath.addLine(to: CGPoint(x: radius * 0.01, y: -radius * 0.05))
    minuteLumePath.addLine(to: CGPoint(x: -radius * 0.01, y: -radius * 0.05))
    minuteLumePath.addLine(to: CGPoint(x: -radius * 0.02, y: -radius * 0.1))
    minuteLumePath.closeSubpath()
    
    context.fill(minuteLumePath, with: .color(vostokLumeColor.opacity(0.7)))
    
    context.rotate(by: .degrees(-minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Second hand - red with counterbalance
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(secondAngle))
    
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.2))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.7))
    
    context.stroke(
        secondPath,
        with: .color(vostokSecondHandColor),
        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
    )
    
    // Counterbalance
    let counterbalance = Path(ellipseIn: CGRect(
        x: -radius * 0.03,
        y: radius * 0.15 - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    context.fill(counterbalance, with: .color(vostokSecondHandColor))
    
    context.rotate(by: .degrees(-secondAngle))
    context.translateBy(x: -center.x, y: -center.y)
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.02,
        y: center.y - radius * 0.02,
        width: radius * 0.04,
        height: radius * 0.04
    ))
    context.fill(centerDot, with: .color(vostokHandsColor))
}

// MARK: - Preview

struct VostokRussianMilitaryWatch_Previews: PreviewProvider {
    static var previews: some View {
        VostokRussianMilitaryWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
