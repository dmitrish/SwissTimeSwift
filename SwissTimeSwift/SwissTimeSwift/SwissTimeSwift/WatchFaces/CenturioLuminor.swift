//
//  CenturioLuminor.swift
//  SwissTimeSwift
//
//  Created by Shpinar Dmitri on 12/12/25.
//


import SwiftUI

struct CenturioLuminor: View {
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
                    
                    drawHourHand(context: context, center: center, radius: radius, angle: hourAngle)
                    drawMinuteHand(context: context, center: center, radius: radius, angle: minuteAngle)
                    drawSecondHand(context: context, center: center, radius: radius, angle: secondAngle)
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

private let clockFaceStartColor = Color(red: 0.118, green: 0.337, blue: 0.192)  // Dark green
private let clockFaceEndColor = Color(red: 0.039, green: 0.153, blue: 0.078)    // Darker green
private let clockBorderColor = Color(red: 0.878, green: 0.878, blue: 0.878)     // Light gray
private let handColor = Color(red: 0.878, green: 0.878, blue: 0.878)            // Light gray
private let secondHandColor = Color(red: 0.878, green: 0.878, blue: 0.878)      // Light gray
private let markersColor = Color(red: 0.878, green: 0.878, blue: 0.878)         // Light gray
private let logoColor = Color(red: 0.878, green: 0.878, blue: 0.878)            // Light gray

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Radial gradient background
    let gradient = Gradient(colors: [clockFaceStartColor, clockFaceEndColor])
    let radialGradient = GraphicsContext.Shading.radialGradient(
        gradient,
        center: center,
        startRadius: 0,
        endRadius: radius * 0.95
    )
    
    let dialCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.95,
        y: center.y - radius * 0.95,
        width: radius * 1.9,
        height: radius * 1.9
    ))
    context.fill(dialCircle, with: radialGradient)
    
    // Outer border
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: 8)
}

private func drawHourMarkers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i)
        let markerLength = radius * 0.1
        let startRadius = radius * 0.8
        
        let startX = center.x + CGFloat(cos(angle)) * startRadius
        let startY = center.y + CGFloat(sin(angle)) * startRadius
        let endX = center.x + CGFloat(cos(angle)) * (startRadius - markerLength)
        let endY = center.y + CGFloat(sin(angle)) * (startRadius - markerLength)
        
        var path = Path()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        let strokeWidth: CGFloat = (i % 3 == 0) ? 3 : 1.5
        context.stroke(
            path,
            with: .color(markersColor),
            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
        )
    }
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Brand name
    let brandText = Text("Centurio Luminor")
        .font(.system(size: radius * 0.1, weight: .regular))
        .foregroundColor(logoColor)
    
    context.draw(brandText, at: CGPoint(x: center.x, y: center.y - radius * 0.3))
    
    // Year text
    let yearText = Text("1728")
        .font(.system(size: radius * 0.06, weight: .regular))
        .foregroundColor(logoColor)
    
    context.draw(yearText, at: CGPoint(x: center.x, y: center.y + radius * 0.4))
}

private func drawHourHand(context: GraphicsContext, center: CGPoint, radius: CGFloat, angle: Double) {
    var handContext = context
    handContext.translateBy(x: center.x, y: center.y)
    handContext.rotate(by: .degrees(angle))
    
    var path = Path()
    path.move(to: CGPoint(x: 0, y: -radius * 0.5))
    
    // Right side curve
    path.addQuadCurve(
        to: CGPoint(x: radius * 0.015, y: 0),
        control: CGPoint(x: radius * 0.03, y: -radius * 0.25)
    )
    
    // Bottom curve
    path.addQuadCurve(
        to: CGPoint(x: -radius * 0.015, y: 0),
        control: CGPoint(x: 0, y: radius * 0.05)
    )
    
    // Left side curve
    path.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.5),
        control: CGPoint(x: -radius * 0.03, y: -radius * 0.25)
    )
    
    path.closeSubpath()
    handContext.fill(path, with: .color(handColor))
}

private func drawMinuteHand(context: GraphicsContext, center: CGPoint, radius: CGFloat, angle: Double) {
    var handContext = context
    handContext.translateBy(x: center.x, y: center.y)
    handContext.rotate(by: .degrees(angle))
    
    var path = Path()
    path.move(to: CGPoint(x: 0, y: -radius * 0.7))
    
    // Right side curve
    path.addQuadCurve(
        to: CGPoint(x: radius * 0.01, y: 0),
        control: CGPoint(x: radius * 0.025, y: -radius * 0.35)
    )
    
    // Bottom curve
    path.addQuadCurve(
        to: CGPoint(x: -radius * 0.01, y: 0),
        control: CGPoint(x: 0, y: radius * 0.05)
    )
    
    // Left side curve
    path.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.7),
        control: CGPoint(x: -radius * 0.025, y: -radius * 0.35)
    )
    
    path.closeSubpath()
    handContext.fill(path, with: .color(handColor))
}

private func drawSecondHand(context: GraphicsContext, center: CGPoint, radius: CGFloat, angle: Double) {
    var handContext = context
    handContext.translateBy(x: center.x, y: center.y)
    handContext.rotate(by: .degrees(angle))
    
    var path = Path()
    path.move(to: CGPoint(x: 0, y: radius * 0.2))
    path.addLine(to: CGPoint(x: 0, y: -radius * 0.8))
    
    handContext.stroke(
        path,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 1, lineCap: .round)
    )
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.02,
        y: center.y - radius * 0.02,
        width: radius * 0.04,
        height: radius * 0.04
    ))
    context.fill(centerDot, with: .color(handColor))
}

// MARK: - Preview

struct CenturioLuminor_Previews: PreviewProvider {
    static var previews: some View {
        CenturioLuminor()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}