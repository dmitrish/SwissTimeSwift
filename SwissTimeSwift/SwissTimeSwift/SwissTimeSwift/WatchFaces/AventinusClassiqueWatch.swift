import SwiftUI

struct AventinusClassiqueWatch: View {
    let timeZone: TimeZone

    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(timeZone: TimeZone = .current) {
        self.timeZone = timeZone
    }

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        return cal
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size / 2 * 0.8
            
            ZStack {
                // Static content
                Canvas { context, canvasSize in
                    drawClockFace(context: context, center: center, radius: radius)
                    drawHourMarkersAndNumbers(context: context, center: center, radius: radius)
                    drawGuillochePattern(context: context, center: center, radius: radius)
                    drawLogo(context: context, center: center, radius: radius)
                }
                
                // Animated content
                Canvas { context, canvasSize in
                    let hour = Double(calendar.component(.hour, from: currentTime) % 12)
                    let minute = Double(calendar.component(.minute, from: currentTime))
                    let second = Double(calendar.component(.second, from: currentTime))
                    
                    let hourDegrees = hour * 30 + minute * 0.5
                    let hourAngle = hourDegrees * .pi / 180 - .pi / 2
                    
                    let minuteDegrees = minute * 6 + second * 0.1
                    let minuteAngle = minuteDegrees * .pi / 180 - .pi / 2
                    
                    let secondDegrees = second * 6
                    let secondAngle = secondDegrees * .pi / 180 - .pi / 2
                    
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
private let clockFaceColor = Color(hex: "F5F5F0")
private let clockBorderColor = Color(hex: "D4AF37")
private let hourHandColor = Color(hex: "000080")
private let minuteHandColor = Color(hex: "000080")
private let secondHandColor = Color(hex: "000080")
private let markersColor = Color.black
private let numbersColor = Color.black
private let accentColor = Color(hex: "D4AF37")

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Outer border (fluted bezel)
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: radius * 0.08)
    
    // Inner fluted pattern
    let flutesCount = 60
    for i in 0..<flutesCount {
        let angle = CGFloat(i) * 360.0 / CGFloat(flutesCount) * .pi / 180.0
        let outerRadius = radius * 0.96
        let innerRadius = radius * 0.92
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + cos(angle) * innerRadius,
            y: center.y + sin(angle) * innerRadius
        ))
        path.addLine(to: CGPoint(
            x: center.x + cos(angle) * outerRadius,
            y: center.y + sin(angle) * outerRadius
        ))
        context.stroke(path, with: .color(clockBorderColor), lineWidth: 1)
    }
    
    // Main face
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.9,
        y: center.y - radius * 0.9,
        width: radius * 1.8,
        height: radius * 1.8
    ))
    context.fill(innerCircle, with: .color(clockFaceColor))
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let romanNumerals = ["XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"]
    
    for i in 0..<12 {
        let angle = .pi / 6.0 * Double(i) - .pi / 2.0
        let numberRadius = radius * 0.75
        
        let numberPos = CGPoint(
            x: center.x + CGFloat(cos(angle)) * numberRadius,
            y: center.y + CGFloat(sin(angle)) * numberRadius
        )
        
        context.draw(
            Text(romanNumerals[i])
                .font(.system(size: radius * 0.15, design: .serif))
                .foregroundColor(numbersColor),
            at: numberPos
        )
        
        // Minute markers
        for j in 0..<5 {
            let minuteAngle = .pi / 30.0 * Double(i * 5 + j) - .pi / 2.0
            let innerRadius = radius * 0.85
            let outerRadius = radius * 0.88
            
            var path = Path()
            path.move(to: CGPoint(
                x: center.x + CGFloat(cos(minuteAngle)) * innerRadius,
                y: center.y + CGFloat(sin(minuteAngle)) * innerRadius
            ))
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cos(minuteAngle)) * outerRadius,
                y: center.y + CGFloat(sin(minuteAngle)) * outerRadius
            ))
            context.stroke(path, with: .color(markersColor), lineWidth: 0.5)
        }
    }
}

private func drawGuillochePattern(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let guillocheRadius = radius * 0.6
    let circleCount = 15
    let circleSpacing = guillocheRadius / CGFloat(circleCount)
    
    // Concentric circles
    for i in 1...circleCount {
        let currentRadius = guillocheRadius - (CGFloat(i) * circleSpacing)
        let circle = Path(ellipseIn: CGRect(
            x: center.x - currentRadius,
            y: center.y - currentRadius,
            width: currentRadius * 2,
            height: currentRadius * 2
        ))
        context.stroke(circle, with: .color(Color(hex: "EEEEE0")), lineWidth: 0.3)
    }
    
    // Cross-hatching
    for angle in stride(from: 0, to: 360, by: 10) {
        let radians = Double(angle) * .pi / 180.0
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(radians)) * (radius * 0.1),
            y: center.y + CGFloat(sin(radians)) * (radius * 0.1)
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(radians)) * guillocheRadius,
            y: center.y + CGFloat(sin(radians)) * guillocheRadius
        ))
        context.stroke(path, with: .color(Color(hex: "EEEEE0")), lineWidth: 0.5)
    }
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    context.draw(
        Text("AVENTINUS")
            .font(.system(size: radius * 0.1, design: .serif))
            .italic()
            .foregroundColor(numbersColor),
        at: CGPoint(x: center.x, y: center.y - radius * 0.3)
    )
    
    context.draw(
        Text("No. 1947")
            .font(.system(size: radius * 0.06, design: .serif))
            .italic()
            .foregroundColor(numbersColor),
        at: CGPoint(x: center.x, y: center.y + radius * 0.4)
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
    var context = context  // Make context mutable
    
    // Hour hand
    var hourPath = Path()
    hourPath.move(to: CGPoint(x: 0, y: -radius * 0.5))
    hourPath.addQuadCurve(
        to: CGPoint(x: radius * 0.02, y: -radius * 0.45),
        control: CGPoint(x: radius * 0.03, y: -radius * 0.48)
    )
    hourPath.addLine(to: CGPoint(x: radius * 0.02, y: 0))
    hourPath.addLine(to: CGPoint(x: -radius * 0.02, y: 0))
    hourPath.addLine(to: CGPoint(x: -radius * 0.02, y: -radius * 0.45))
    hourPath.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.5),
        control: CGPoint(x: -radius * 0.03, y: -radius * 0.48)
    )
    hourPath.closeSubpath()
    
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: Angle(radians: hourAngle))
    context.fill(hourPath, with: .color(hourHandColor))
    context.rotate(by: Angle(radians: -hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand
    var minutePath = Path()
    minutePath.move(to: CGPoint(x: 0, y: -radius * 0.7))
    minutePath.addQuadCurve(
        to: CGPoint(x: radius * 0.015, y: -radius * 0.65),
        control: CGPoint(x: radius * 0.025, y: -radius * 0.68)
    )
    minutePath.addLine(to: CGPoint(x: radius * 0.015, y: 0))
    minutePath.addLine(to: CGPoint(x: -radius * 0.015, y: 0))
    minutePath.addLine(to: CGPoint(x: -radius * 0.015, y: -radius * 0.65))
    minutePath.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.7),
        control: CGPoint(x: -radius * 0.025, y: -radius * 0.68)
    )
    minutePath.closeSubpath()
    
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: Angle(radians: minuteAngle))
    context.fill(minutePath, with: .color(minuteHandColor))
    context.rotate(by: Angle(radians: -minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Second hand
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.2))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.8))
    
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: Angle(radians: secondAngle))
    context.stroke(secondPath, with: .color(secondHandColor), style: StrokeStyle(lineWidth: 0.7, lineCap: .round))
    
    // Counterbalance
    let counterbalance = Path(ellipseIn: CGRect(
        x: -radius * 0.03,
        y: radius * 0.15 - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    context.fill(counterbalance, with: .color(secondHandColor))
    
    context.rotate(by: Angle(radians: -secondAngle))
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

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview
#Preview {
    AventinusClassiqueWatch()
        .frame(width: 300, height: 300)
        .background(Color.black)
}
