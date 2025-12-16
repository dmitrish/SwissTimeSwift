


import SwiftUI

struct KandinskyEvening: View {
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
                    
                    let hourAngle = Double(hour) * 30.0 + Double(minute) * 0.5
                    let minuteAngle = Double(minute) * 6.0
                    let secondAngle = Double(second) * 6.0
                    
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

// MARK: - Colors (Kandinsky's "Circles in a Circle" inspired)

private let backgroundColor = Color(red: 0.961, green: 0.961, blue: 0.961)  // Light background
private let clockBorderColor = Color.black
private let hourHandColor = Color(red: 1.0, green: 0.498, blue: 0.314)      // Orange
private let minuteHandColor = Color(red: 1.0, green: 0.498, blue: 0.314)    // Orange
private let secondHandColor = Color(red: 0.820, green: 0.231, blue: 0.251)  // Red
private let markersColor = Color.black
private let logoColor = Color.black

// Kandinsky circle colors
private let kandinskyBlue = Color(red: 0.114, green: 0.365, blue: 0.780)
private let kandinskyRed = Color(red: 0.820, green: 0.231, blue: 0.251)
private let kandinskyYellow = Color(red: 1.0, green: 0.784, blue: 0.341)
private let kandinskyGreen = Color(red: 0.180, green: 0.545, blue: 0.341)
private let kandinskyPurple = Color(red: 0.576, green: 0.439, blue: 0.859)
private let kandinskyOrange = Color(red: 1.0, green: 0.498, blue: 0.314)

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Light background like in Kandinsky's painting
    let backgroundCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.95,
        y: center.y - radius * 0.95,
        width: radius * 1.9,
        height: radius * 1.9
    ))
    context.fill(backgroundCircle, with: .color(backgroundColor))
    
    // Main outer circle (black border)
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: 8)
    
    // Draw Kandinsky's "Circles in a Circle" inspired design
    let lineWidth: CGFloat = 3
    
    // Diagonal line from top-left to bottom-right
    var diag1 = Path()
    diag1.move(to: CGPoint(x: center.x - radius * 0.7, y: center.y - radius * 0.7))
    diag1.addLine(to: CGPoint(x: center.x + radius * 0.7, y: center.y + radius * 0.7))
    context.stroke(diag1, with: .color(clockBorderColor), lineWidth: lineWidth)
    
    // Diagonal line from top-right to bottom-left
    var diag2 = Path()
    diag2.move(to: CGPoint(x: center.x + radius * 0.7, y: center.y - radius * 0.7))
    diag2.addLine(to: CGPoint(x: center.x - radius * 0.7, y: center.y + radius * 0.7))
    context.stroke(diag2, with: .color(clockBorderColor), lineWidth: lineWidth)
    
    // Horizontal line
    var horizontal = Path()
    horizontal.move(to: CGPoint(x: center.x - radius * 0.7, y: center.y))
    horizontal.addLine(to: CGPoint(x: center.x + radius * 0.7, y: center.y))
    context.stroke(horizontal, with: .color(clockBorderColor), lineWidth: lineWidth)
    
    // Vertical line
    var vertical = Path()
    vertical.move(to: CGPoint(x: center.x, y: center.y - radius * 0.7))
    vertical.addLine(to: CGPoint(x: center.x, y: center.y + radius * 0.7))
    context.stroke(vertical, with: .color(clockBorderColor), lineWidth: lineWidth)
    
    // Draw multiple colored circles of various sizes
    
    // Large blue circle in top-left quadrant
    let blueCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.4 - radius * 0.25,
        y: center.y - radius * 0.4 - radius * 0.25,
        width: radius * 0.5,
        height: radius * 0.5
    ))
    context.fill(blueCircle, with: .color(kandinskyBlue))
    
    // Medium red circle in top-right quadrant
    let redCircle = Path(ellipseIn: CGRect(
        x: center.x + radius * 0.5 - radius * 0.2,
        y: center.y - radius * 0.3 - radius * 0.2,
        width: radius * 0.4,
        height: radius * 0.4
    ))
    context.fill(redCircle, with: .color(kandinskyRed))
    
    // Small yellow circle in bottom-left quadrant
    let yellowCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.5 - radius * 0.15,
        y: center.y + radius * 0.4 - radius * 0.15,
        width: radius * 0.3,
        height: radius * 0.3
    ))
    context.fill(yellowCircle, with: .color(kandinskyYellow))
    
    // Medium green circle in bottom-right quadrant
    let greenCircle = Path(ellipseIn: CGRect(
        x: center.x + radius * 0.4 - radius * 0.18,
        y: center.y + radius * 0.5 - radius * 0.18,
        width: radius * 0.36,
        height: radius * 0.36
    ))
    context.fill(greenCircle, with: .color(kandinskyGreen))
    
    // Small purple circle near center
    let purpleCircle = Path(ellipseIn: CGRect(
        x: center.x + radius * 0.1 - radius * 0.12,
        y: center.y - radius * 0.2 - radius * 0.12,
        width: radius * 0.24,
        height: radius * 0.24
    ))
    context.fill(purpleCircle, with: .color(kandinskyPurple))
    
    // Small orange circle near center
    let orangeCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.2 - radius * 0.1,
        y: center.y + radius * 0.1 - radius * 0.1,
        width: radius * 0.2,
        height: radius * 0.2
    ))
    context.fill(orangeCircle, with: .color(kandinskyOrange))
    
    // Additional smaller circles for more detail
    let smallBlue = Path(ellipseIn: CGRect(
        x: center.x + radius * 0.3 - radius * 0.08,
        y: center.y + radius * 0.1 - radius * 0.08,
        width: radius * 0.16,
        height: radius * 0.16
    ))
    context.fill(smallBlue, with: .color(kandinskyBlue.opacity(0.7)))
    
    let smallRed = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.3 - radius * 0.06,
        y: center.y - radius * 0.2 - radius * 0.06,
        width: radius * 0.12,
        height: radius * 0.12
    ))
    context.fill(smallRed, with: .color(kandinskyRed.opacity(0.7)))
    
    let smallYellow = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.07,
        y: center.y + radius * 0.3 - radius * 0.07,
        width: radius * 0.14,
        height: radius * 0.14
    ))
    context.fill(smallYellow, with: .color(kandinskyYellow.opacity(0.7)))
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
    // Brand text (empty string in original)
    let brandText = Text("")
        .font(.system(size: radius * 0.1, weight: .regular))
        .foregroundColor(logoColor)
    
    context.draw(brandText, at: CGPoint(x: center.x, y: center.y - radius * 0.3))
    
    // "W K" text at bottom
    let wkText = Text("W  K")
        .font(.system(size: radius * 0.06, weight: .regular))
        .foregroundColor(logoColor)
    
    context.draw(wkText, at: CGPoint(x: center.x - 2, y: center.y + radius * 0.5))
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
    handContext.fill(path, with: .color(hourHandColor))
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
    handContext.fill(path, with: .color(minuteHandColor))
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
    context.fill(centerDot, with: .color(hourHandColor))
}

// MARK: - Preview

struct KandinskyEvening_Previews: PreviewProvider {
    static var previews: some View {
        KandinskyEvening()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
