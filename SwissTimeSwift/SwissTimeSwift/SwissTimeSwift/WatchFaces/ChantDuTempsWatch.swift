
import SwiftUI

struct ChantDuTempsWatch: View {
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
                    drawHourMarkers(context: context, center: center, radius: radius)
                    drawSubtlePattern(context: context, center: center, radius: radius)
                    drawLogo(context: context, center: center, radius: radius)
                }
                
                // Animated content
                Canvas { context, canvasSize in
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: currentTime) % 12
                    let minute = calendar.component(.minute, from: currentTime)
                    let second = calendar.component(.second, from: currentTime)
                    
                    let hourAngle = Double(hour) * 30.0 + Double(minute) * 0.5
                    let minuteAngle = Double(minute) * 6.0
                    let secondAngle = Double(second) * 6.0
                    
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

// MARK: - Colors (Vacheron Constantin Patrimony inspired)

private let clockFaceColor = Color(red: 0xF8/255.0, green: 0xF5/255.0, blue: 0xE6/255.0) // Cream dial
private let clockBorderColor = Color(red: 0xB8/255.0, green: 0x86/255.0, blue: 0x0B/255.0) // Dark gold border
private let hourHandColor = Color(red: 0x4A/255.0, green: 0x4A/255.0, blue: 0x4A/255.0) // Dark gray hour hand
private let minuteHandColor = Color(red: 0x4A/255.0, green: 0x4A/255.0, blue: 0x4A/255.0) // Dark gray minute hand
private let secondHandColor = Color(red: 0x8B/255.0, green: 0x00/255.0, blue: 0x00/255.0) // Dark red second hand
private let markersColor = Color(red: 0xB8/255.0, green: 0x86/255.0, blue: 0x0B/255.0) // Gold markers
private let numbersColor = Color(red: 0x4A/255.0, green: 0x4A/255.0, blue: 0x4A/255.0) // Dark gray numbers
private let accentColor = Color(red: 0xB8/255.0, green: 0x86/255.0, blue: 0x0B/255.0) // Gold accent

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Outer border
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: radius * 0.03)
    
    // Main face
    let mainFace = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.97,
        y: center.y - radius * 0.97,
        width: radius * 1.94,
        height: radius * 1.94
    ))
    context.fill(mainFace, with: .color(clockFaceColor))
    
    // Subtle inner ring
    let innerRing = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.92,
        y: center.y - radius * 0.92,
        width: radius * 1.84,
        height: radius * 1.84
    ))
    context.stroke(innerRing, with: .color(clockBorderColor), lineWidth: radius * 0.005)
}

private func drawHourMarkers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i) - Double.pi / 2
        let markerRadius = radius * 0.85
        
        let markerX = center.x + CGFloat(cos(angle)) * markerRadius
        let markerY = center.y + CGFloat(sin(angle)) * markerRadius
        
        // Applied gold markers
        if i % 3 == 0 {
            // Double marker for 12, 3, 6, 9
            var path = Path()
            let perpAngle = angle + Double.pi / 2
            
            path.move(to: CGPoint(
                x: markerX - CGFloat(cos(perpAngle)) * radius * 0.03,
                y: markerY - CGFloat(sin(perpAngle)) * radius * 0.03
            ))
            path.addLine(to: CGPoint(
                x: markerX + CGFloat(cos(perpAngle)) * radius * 0.03,
                y: markerY + CGFloat(sin(perpAngle)) * radius * 0.03
            ))
            
            context.stroke(
                path,
                with: .color(markersColor),
                style: StrokeStyle(lineWidth: radius * 0.02, lineCap: .round)
            )
        } else {
            // Single marker for other hours
            let marker = Path(ellipseIn: CGRect(
                x: markerX - radius * 0.01,
                y: markerY - radius * 0.01,
                width: radius * 0.02,
                height: radius * 0.02
            ))
            context.fill(marker, with: .color(markersColor))
        }
        
        // Minute markers
        if i < 11 {
            for j in 1..<5 {
                let minuteAngle = Double.pi / 30 * Double(i * 5 + j) - Double.pi / 2
                let minuteMarkerRadius = radius * 0.88
                
                let minuteX = center.x + CGFloat(cos(minuteAngle)) * minuteMarkerRadius
                let minuteY = center.y + CGFloat(sin(minuteAngle)) * minuteMarkerRadius
                
                let minuteMarker = Path(ellipseIn: CGRect(
                    x: minuteX - radius * 0.003,
                    y: minuteY - radius * 0.003,
                    width: radius * 0.006,
                    height: radius * 0.006
                ))
                context.fill(minuteMarker, with: .color(markersColor))
            }
        }
    }
}

private func drawSubtlePattern(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Subtle sunburst pattern
    let patternRadius = radius * 0.5
    
    for angle in stride(from: 0, to: 360, by: 6) {
        let radians = Double(angle) * Double.pi / 180
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(radians)) * (radius * 0.1),
            y: center.y + CGFloat(sin(radians)) * (radius * 0.1)
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(radians)) * patternRadius,
            y: center.y + CGFloat(sin(radians)) * patternRadius
        ))
        
        context.stroke(
            path,
            with: .color(Color(red: 0xF5/255.0, green: 0xF0/255.0, blue: 0xE0/255.0)),
            lineWidth: 0.5
        )
    }
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw Maltese cross (Vacheron Constantin's logo)
    let crossSize = radius * 0.12
    let crossY = center.y - radius * 0.3
    
    var crossPath = Path()
    crossPath.move(to: CGPoint(x: center.x, y: crossY - crossSize))
    crossPath.addLine(to: CGPoint(x: center.x + crossSize * 0.3, y: crossY - crossSize * 0.7))
    crossPath.addLine(to: CGPoint(x: center.x + crossSize, y: crossY - crossSize * 0.3))
    crossPath.addLine(to: CGPoint(x: center.x + crossSize * 0.7, y: crossY))
    crossPath.addLine(to: CGPoint(x: center.x + crossSize, y: crossY + crossSize * 0.3))
    crossPath.addLine(to: CGPoint(x: center.x + crossSize * 0.3, y: crossY + crossSize * 0.7))
    crossPath.addLine(to: CGPoint(x: center.x, y: crossY + crossSize))
    crossPath.addLine(to: CGPoint(x: center.x - crossSize * 0.3, y: crossY + crossSize * 0.7))
    crossPath.addLine(to: CGPoint(x: center.x - crossSize, y: crossY + crossSize * 0.3))
    crossPath.addLine(to: CGPoint(x: center.x - crossSize * 0.7, y: crossY))
    crossPath.addLine(to: CGPoint(x: center.x - crossSize, y: crossY - crossSize * 0.3))
    crossPath.addLine(to: CGPoint(x: center.x - crossSize * 0.3, y: crossY - crossSize * 0.7))
    crossPath.closeSubpath()
    
    context.fill(crossPath, with: .color(accentColor))
    
    // Brand name
    context.draw(
        Text("CHANT DU TEMPS")
            .font(.system(size: radius * 0.08, design: .serif))
            .foregroundColor(numbersColor),
        at: CGPoint(x: center.x, y: center.y - radius * 0.15)
    )
    
    // "GENÈVE" text
    context.draw(
        Text("GENÈVE")
            .font(.system(size: radius * 0.05))
            .foregroundColor(numbersColor),
        at: CGPoint(x: center.x, y: center.y + radius * 0.4)
    )
    
    // "SWISS MADE" text
    context.draw(
        Text("SWISS MADE")
            .font(.system(size: radius * 0.04))
            .foregroundColor(numbersColor),
        at: CGPoint(x: center.x, y: center.y + radius * 0.5)
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
    
    // Hour hand - Dauphine-style (diamond-shaped)
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(hourAngle))
    
    var hourPath = Path()
    hourPath.move(to: CGPoint(x: 0, y: -radius * 0.5))          // Tip
    hourPath.addLine(to: CGPoint(x: radius * 0.03, y: -radius * 0.35))  // Right shoulder
    hourPath.addLine(to: CGPoint(x: radius * 0.01, y: 0))                // Right base
    hourPath.addLine(to: CGPoint(x: -radius * 0.01, y: 0))               // Left base
    hourPath.addLine(to: CGPoint(x: -radius * 0.03, y: -radius * 0.35)) // Left shoulder
    hourPath.closeSubpath()
    
    context.fill(hourPath, with: .color(hourHandColor))
    
    context.rotate(by: .degrees(-hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand - Dauphine-style (diamond-shaped)
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(minuteAngle))
    
    var minutePath = Path()
    minutePath.move(to: CGPoint(x: 0, y: -radius * 0.7))           // Tip
    minutePath.addLine(to: CGPoint(x: radius * 0.025, y: -radius * 0.5))  // Right shoulder
    minutePath.addLine(to: CGPoint(x: radius * 0.008, y: 0))               // Right base
    minutePath.addLine(to: CGPoint(x: -radius * 0.008, y: 0))              // Left base
    minutePath.addLine(to: CGPoint(x: -radius * 0.025, y: -radius * 0.5)) // Left shoulder
    minutePath.closeSubpath()
    
    context.fill(minutePath, with: .color(minuteHandColor))
    
    context.rotate(by: .degrees(-minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Second hand - thin with counterbalance
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(secondAngle))
    
    // Main hand
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.2))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.8))
    
    context.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 1, lineCap: .round)
    )
    
    // Counterbalance
    let counterbalance = Path(ellipseIn: CGRect(
        x: -radius * 0.03,
        y: radius * 0.15 - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    context.fill(counterbalance, with: .color(secondHandColor))
    
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
    context.fill(centerDot, with: .color(accentColor))
}

// MARK: - Preview

struct ChantDuTempsWatch_Previews: PreviewProvider {
    static var previews: some View {
        ChantDuTempsWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
