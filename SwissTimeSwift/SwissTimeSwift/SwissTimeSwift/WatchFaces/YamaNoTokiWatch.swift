
import SwiftUI

struct YamaNoTokiWatch: View {
    let timeZone: TimeZone

    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                    drawHourMarkersAndNumbers(context: context, center: center, radius: radius, currentTime: currentTime, calendar: calendar)
                }
                
                // Animated content
                Canvas { context, canvasSize in
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
                        minuteAngle: minuteAngle
                    )
                    
                    drawSubdialSecondHand(
                        context: context,
                        center: center,
                        radius: radius,
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

// MARK: - Colors (Chopard L.U.C inspired)

private let clockFaceColor = Color(red: 0xFA/255.0, green: 0xF0/255.0, blue: 0xE6/255.0) // Ivory/cream
private let clockBorderColor = Color(red: 0xB8/255.0, green: 0x86/255.0, blue: 0x0B/255.0) // Dark gold
private let hourHandColor = Color.black
private let minuteHandColor = Color.black
private let secondHandColor = Color(red: 0xB2/255.0, green: 0x22/255.0, blue: 0x22/255.0) // Red
private let markersColor = Color.black
private let numbersColor = Color.black
private let powerReserveColor = Color(red: 0xB8/255.0, green: 0x86/255.0, blue: 0x0B/255.0)
private let centerDotColor = Color.black

// MARK: - Border width constant
private let outerBorderWidth: CGFloat = 2 // changed from 6 to 2

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Face radius sits just inside half the stroke width
    let faceRadius = radius - outerBorderWidth / 2

    // Outer circle (border)
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: outerBorderWidth)
    
    // Inner circle (face)
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - faceRadius,
        y: center.y - faceRadius,
        width: faceRadius * 2,
        height: faceRadius * 2
    ))
    context.fill(innerCircle, with: .color(clockFaceColor))
    
    // Elaborate guilloche pattern - central sunburst
    for i in 0..<72 {
        let angle = Double.pi * 2 * Double(i) / 72
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius * 0.1,
            y: center.y + CGFloat(sin(angle)) * radius * 0.1
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius * 0.5,
            y: center.y + CGFloat(sin(angle)) * radius * 0.5
        ))
        
        context.stroke(path, with: .color(.black.opacity(0.05)), lineWidth: 1)
    }
    
    // Outer circular guilloche pattern
    for i in 0..<180 {
        let angle = Double.pi * 2 * Double(i) / 180
        let radius1 = radius * 0.5
        let radius2 = radius * 0.85
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius1,
            y: center.y + CGFloat(sin(angle)) * radius1
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius2,
            y: center.y + CGFloat(sin(angle)) * radius2
        ))
        
        context.stroke(path, with: .color(.black.opacity(0.03)), lineWidth: 0.5)
    }
    
    // Chopard logo (Japanese characters)
    context.draw(
        Text("山の時")
            .font(.system(size: radius * 0.12, weight: .bold))
            .foregroundColor(.black),
        at: CGPoint(x: center.x, y: center.y - radius * 0.3)
    )
    
    // "Yama-no-Toki" text
    context.draw(
        Text("Yama-no-Toki")
            .font(.system(size: radius * 0.08))
            .foregroundColor(.black),
        at: CGPoint(x: center.x, y: center.y - radius * 0.15)
    )
    
    // Power reserve indicator at 6 o'clock
    let powerReserveY = center.y + radius * 0.4
    let powerReserveWidth = radius * 0.4
    let powerReserveHeight = radius * 0.1
    
    // Power reserve background
   /* let powerReserveRect = Path(CGRect(
        x: center.x - powerReserveWidth / 2,
        y: powerReserveY - powerReserveHeight / 2,
        width: powerReserveWidth,
        height: powerReserveHeight
    ))
    context.fill(powerReserveRect, with: .color(.white))
    context.stroke(powerReserveRect, with: .color(.black), lineWidth: 0.3)
    
    // Power reserve markings
    for i in 0...8 {
        let x = center.x - powerReserveWidth / 2 + powerReserveWidth * CGFloat(i) / 8
        
        var path = Path()
        path.move(to: CGPoint(x: x, y: powerReserveY - powerReserveHeight / 2))
        path.addLine(to: CGPoint(x: x, y: powerReserveY - powerReserveHeight / 4))
        
        context.stroke(path, with: .color(.black), lineWidth: i % 2 == 0 ? 1.5 : 0.5)
    }
    
    // Power reserve text
    context.draw(
        Text("POWER RESERVE")
            .font(.system(size: powerReserveHeight * 0.6))
            .foregroundColor(.black),
        at: CGPoint(x: center.x, y: powerReserveY + powerReserveHeight / 4)
    ) */
    
    // Power reserve indicator (75% full)
   /* let indicatorWidth = powerReserveWidth * 0.75
    let indicator = Path(CGRect(
        x: center.x - powerReserveWidth / 2,
        y: powerReserveY - powerReserveHeight / 2,
        width: indicatorWidth,
        height: powerReserveHeight
    ))
    context.fill(indicator, with: .color(powerReserveColor))*/
    
    // Small seconds subdial at 6 o'clock
    let secondsSubdialY = center.y + radius * 0.25
    let secondsSubdialRadius = radius * 0.15
    
    // Subdial background
    let subdialCircle = Path(ellipseIn: CGRect(
        x: center.x - secondsSubdialRadius,
        y: secondsSubdialY - secondsSubdialRadius,
        width: secondsSubdialRadius * 2,
        height: secondsSubdialRadius * 2
    ))
    context.fill(subdialCircle, with: .color(.white))
    context.stroke(subdialCircle, with: .color(.black), lineWidth: 0.3)
    
    // Subdial markers
    for i in 0..<60 {
        let angle = Double.pi * 2 * Double(i) / 60
        let markerLength: CGFloat = i % 5 == 0 ? secondsSubdialRadius * 0.2 : secondsSubdialRadius * 0.1
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * (secondsSubdialRadius - markerLength),
            y: secondsSubdialY + CGFloat(sin(angle)) * (secondsSubdialRadius - markerLength)
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * secondsSubdialRadius * 0.9,
            y: secondsSubdialY + CGFloat(sin(angle)) * secondsSubdialRadius * 0.9
        ))
        
        context.stroke(path, with: .color(.black), lineWidth: i % 15 == 0 ? 0.7 : 0.3)
    }
    
    // Subdial numbers (60, 15, 30, 45)
    let secondsNumbers = ["60", "15", "30", "45"]
    for i in 0...3 {
        let angle = Double.pi / 2 * Double(i)
        
        context.draw(
            Text(secondsNumbers[i])
                .font(.system(size: secondsSubdialRadius * 0.3))
                .foregroundColor(.black),
            at: CGPoint(
                x: center.x + CGFloat(cos(angle)) * secondsSubdialRadius * 0.7,
                y: secondsSubdialY + CGFloat(sin(angle)) * secondsSubdialRadius * 0.7
            )
        )
    }
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat, currentTime: Date, calendar: Calendar) {
    let markerLength = radius * 0.08
    let markerWidth = radius * 0.02
    
    for i in 0..<12 {
        // Skip 6 o'clock for power reserve and small seconds
        if i == 6 { continue }
        
        let angle = Double.pi / 6 * Double(i) - Double.pi / 2
        let markerX = center.x + CGFloat(cos(angle)) * radius * 0.75
        let markerY = center.y + CGFloat(sin(angle)) * radius * 0.75
        
        var markerContext = context
        markerContext.translateBy(x: markerX, y: markerY)
        markerContext.rotate(by: .degrees(Double(i) * 30))
        
        // Main marker
        let marker = Path(CGRect(
            x: -markerWidth / 2,
            y: -markerLength / 2,
            width: markerWidth,
            height: markerLength
        ))
        markerContext.fill(marker, with: .color(markersColor))
        
        // Gold accent
        let accent = Path(CGRect(
            x: -markerWidth / 2 + 1,
            y: -markerLength / 2 + 1,
            width: markerWidth - 2,
            height: markerLength - 2
        ))
        markerContext.fill(accent, with: .color(clockBorderColor))
    }
    
    // Roman numerals at 12, 3, and 9 o'clock
    let positions = [0, 3, 9]
    let numerals = ["XII", "III", "IX"]
    
    for i in 0..<positions.count {
        let angle = Double.pi / 6 * Double(positions[i]) - Double.pi / 2
        let numberRadius = radius * 0.6
        
        context.draw(
            Text(numerals[i])
                .font(.system(size: radius * 0.1))
                .foregroundColor(numbersColor),
            at: CGPoint(
                x: center.x + CGFloat(cos(angle)) * numberRadius,
                y: center.y + CGFloat(sin(angle)) * numberRadius
            )
        )
    }
    
    // Date window at 4:30 position
    let dateAngle = Double.pi / 6 * 4.5 - Double.pi / 2
    let dateX = center.x + CGFloat(cos(dateAngle)) * radius * 0.55
    let dateY = center.y + CGFloat(sin(dateAngle)) * radius * 0.55
    
    // Date window
    let dateWindow = Path(CGRect(
        x: dateX - radius * 0.08,
        y: dateY - radius * 0.06,
        width: radius * 0.16,
        height: radius * 0.12
    ))
    context.fill(dateWindow, with: .color(.white))
    context.stroke(dateWindow, with: .color(clockBorderColor), lineWidth: 0.3)
    
    // Date text
    let day = calendar.component(.day, from: currentTime)
    
    context.draw(
        Text("\(day)")
            .font(.system(size: radius * 0.08, weight: .bold))
            .foregroundColor(.black),
        at: CGPoint(x: dateX, y: dateY)
    )
}

private func drawClockHands(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    hourAngle: Double,
    minuteAngle: Double
) {
    var context = context
    
    // Hour hand - dauphine-style
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(hourAngle))
    
    var hourHandPath = Path()
    hourHandPath.move(to: CGPoint(x: 0, y: -radius * 0.4))
    hourHandPath.addLine(to: CGPoint(x: radius * 0.04, y: 0))
    hourHandPath.addLine(to: CGPoint(x: 0, y: radius * 0.1))
    hourHandPath.addLine(to: CGPoint(x: -radius * 0.04, y: 0))
    hourHandPath.closeSubpath()
    
    context.fill(hourHandPath, with: .color(hourHandColor))
    
    context.rotate(by: .degrees(-hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand - longer dauphine-style
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(minuteAngle))
    
    var minuteHandPath = Path()
    minuteHandPath.move(to: CGPoint(x: 0, y: -radius * 0.6))
    minuteHandPath.addLine(to: CGPoint(x: radius * 0.03, y: 0))
    minuteHandPath.addLine(to: CGPoint(x: 0, y: radius * 0.1))
    minuteHandPath.addLine(to: CGPoint(x: -radius * 0.03, y: 0))
    minuteHandPath.closeSubpath()
    
    context.fill(minuteHandPath, with: .color(minuteHandColor))
    
    context.rotate(by: .degrees(-minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
}

private func drawSubdialSecondHand(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    secondAngle: Double
) {
    var context = context
    
    let secondsSubdialY = center.y + radius * 0.25
    let secondsSubdialRadius = radius * 0.15
    
    context.translateBy(x: center.x, y: secondsSubdialY)
    context.rotate(by: .degrees(secondAngle))
    
    var secondPath = Path()
    secondPath.move(to: .zero)
    secondPath.addLine(to: CGPoint(x: 0, y: -secondsSubdialRadius * 0.8))
    
    context.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 0.5, lineCap: .round)
    )
    
    context.rotate(by: .degrees(-secondAngle))
    context.translateBy(x: -center.x, y: -secondsSubdialY)
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.03,
        y: center.y - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    context.fill(centerDot, with: .color(centerDotColor))
}

// MARK: - Preview

struct YamaNoTokiWatch_Previews: PreviewProvider {
    static var previews: some View {
        YamaNoTokiWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
