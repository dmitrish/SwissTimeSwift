import SwiftUI

struct ChronomagusRegium: View {
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

private let clockFaceColor = Color(red: 0.0, green: 0.0, blue: 0.502)      // Deep blue dial
private let clockBorderColor = Color.white                                  // White gold case
private let handColor = Color.white                                         // White hands
private let secondHandColor = Color.white                                   // White second hand
private let markersColor = Color.white                                      // White markers
private let logoColor = Color.white                                         // White logo

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw outer circle (case) - very thin to represent the ultra-thin profile
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: 4)
    
    // Draw inner circle (face)
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - (radius - 2),
        y: center.y - (radius - 2),
        width: (radius - 2) * 2,
        height: (radius - 2) * 2
    ))
    context.fill(innerCircle, with: .color(clockFaceColor))
}

private func drawHourMarkers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Chronomagus Regium has very minimalist hour markers
    
    // Draw simple thin lines
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i)
        
        // For 3, 6, 9, and 12 o'clock, use slightly longer markers
        let markerLength = (i % 3 == 0) ? radius * 0.05 : radius * 0.03
        let markerWidth: CGFloat = (i % 3 == 0) ? 1.5 : 1
        
        let startX = center.x + CGFloat(cos(angle)) * (radius * 0.85)
        let startY = center.y + CGFloat(sin(angle)) * (radius * 0.85)
        let endX = center.x + CGFloat(cos(angle)) * (radius * 0.85 - markerLength)
        let endY = center.y + CGFloat(sin(angle)) * (radius * 0.85 - markerLength)
        
        var path = Path()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        context.stroke(
            path,
            with: .color(markersColor),
            style: StrokeStyle(lineWidth: markerWidth, lineCap: .round)
        )
    }
    
    // Add small dots at each hour position for a more refined look
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i)
        let dotRadius: CGFloat = (i % 3 == 0) ? 1.5 : 1
        
        let dotX = center.x + CGFloat(cos(angle)) * (radius * 0.9)
        let dotY = center.y + CGFloat(sin(angle)) * (radius * 0.9)
        
        let dot = Path(ellipseIn: CGRect(
            x: dotX - dotRadius,
            y: dotY - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        ))
        context.fill(dot, with: .color(markersColor))
    }
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // "CHRONOMAGUS" text - thin and elegant
    let brandText = Text("CHRONOMAGUS")
        .font(.system(size: radius * 0.08, weight: .thin))
        .foregroundColor(logoColor)
    
    context.draw(brandText, at: CGPoint(x: center.x, y: center.y - radius * 0.3))
    
    // "REGIUM" text
    let modelText = Text("REGIUM")
        .font(.system(size: radius * 0.06, weight: .light))
        .foregroundColor(logoColor)
    
    context.draw(modelText, at: CGPoint(x: center.x, y: center.y - radius * 0.2))
    
    // "ULTRA-THIN" text - a key feature
    let ultraThinText = Text("ULTRA-THIN")
        .font(.system(size: radius * 0.05, weight: .light))
        .foregroundColor(logoColor)
    
    context.draw(ultraThinText, at: CGPoint(x: center.x, y: center.y + radius * 0.2))
    
    // "Fabricatum Romae" text (Made in Rome)
    let fabricatumText = Text("Fabricatum Romae")
        .font(.system(size: radius * 0.04, weight: .light))
        .foregroundColor(logoColor)
    
    context.draw(fabricatumText, at: CGPoint(x: center.x, y: center.y + radius * 0.5))
}

private func drawClockHands(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    hourAngle: Double,
    minuteAngle: Double,
    secondAngle: Double
) {
    // Hour hand - very thin and elegant
    var hourContext = context
    hourContext.translateBy(x: center.x, y: center.y)
    hourContext.rotate(by: .degrees(hourAngle))
    
    var hourPath = Path()
    hourPath.move(to: .zero)
    hourPath.addLine(to: CGPoint(x: 0, y: -radius * 0.5))
    
    hourContext.stroke(
        hourPath,
        with: .color(handColor),
        style: StrokeStyle(lineWidth: 2, lineCap: .round)
    )
    
    // Minute hand - longer and equally thin
    var minuteContext = context
    minuteContext.translateBy(x: center.x, y: center.y)
    minuteContext.rotate(by: .degrees(minuteAngle))
    
    var minutePath = Path()
    minutePath.move(to: .zero)
    minutePath.addLine(to: CGPoint(x: 0, y: -radius * 0.7))
    
    minuteContext.stroke(
        minutePath,
        with: .color(handColor),
        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
    )
    
    // Second hand - extremely thin
    var secondContext = context
    secondContext.translateBy(x: center.x, y: center.y)
    secondContext.rotate(by: .degrees(secondAngle))
    
    var secondPath = Path()
    secondPath.move(to: .zero)
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.8))
    
    secondContext.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 0.5, lineCap: .round)
    )
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.01,
        y: center.y - radius * 0.01,
        width: radius * 0.02,
        height: radius * 0.02
    ))
    context.fill(centerDot, with: .color(handColor))
}

// MARK: - Preview

struct ChronomagusRegium_Previews: PreviewProvider {
    static var previews: some View {
        ChronomagusRegium()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}