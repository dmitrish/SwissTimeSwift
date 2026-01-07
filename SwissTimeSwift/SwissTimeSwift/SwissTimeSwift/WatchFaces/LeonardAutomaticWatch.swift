
import SwiftUI

struct LeonardAutomaticWatch: View {
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

// MARK: - Colors (Longines Master Collection inspired)

private let clockFaceColor = Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0) // Silver-white
private let clockBorderColor = Color(red: 0x8B/255.0, green: 0x45/255.0, blue: 0x13/255.0) // Brown
private let hourHandColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0) // Dark blue (blued steel)
private let minuteHandColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)
private let secondHandColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)
private let markersColor = Color.black
private let numbersColor = Color.black
private let moonphaseColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x80/255.0) // Navy blue
private let moonColor = Color(red: 0xFF/255.0, green: 0xFA/255.0, blue: 0xCD/255.0) // Light yellow
private let centerDotColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)

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
    
    // Subtle guilloche pattern (concentric circles)
    for i in 1...8 {
        let factor = (0.9 - CGFloat(i) * 0.1)
        let guillocheCircle = Path(ellipseIn: CGRect(
            x: center.x - radius * factor,
            y: center.y - radius * factor,
            width: radius * 2 * factor,
            height: radius * 2 * factor
        ))
        context.stroke(guillocheCircle, with: .color(.black.opacity(0.03)), lineWidth: 1)
    }
    
    // Longines logo
    context.draw(
        Text("LÉONARD")
            .font(.system(size: radius * 0.12, weight: .bold))
            .foregroundColor(.black),
        at: CGPoint(x: center.x, y: center.y - radius * 0.3)
    )
    
    // "AUTOMATIC" text
    context.draw(
        Text("AUTOMATIC")
            .font(.system(size: radius * 0.06))
            .foregroundColor(.black),
        at: CGPoint(x: center.x, y: center.y - radius * 0.15)
    )
    
    // Moonphase display at 6 o'clock
    let moonphaseY = center.y + radius * 0.4
    let moonphaseWidth = radius * 0.4
    let moonphaseHeight = radius * 0.2
    
    // Moonphase background (night sky)
    let moonphaseRect = Path(CGRect(
        x: center.x - moonphaseWidth / 2,
        y: moonphaseY - moonphaseHeight / 2,
        width: moonphaseWidth,
        height: moonphaseHeight
    ))
    context.fill(moonphaseRect, with: .color(moonphaseColor))
    
    // Add stars to the night sky (fixed seed for consistency)
    let seed: UInt64 = 1234
    var generator = SeededRandomNumberGenerator(seed: seed)
    for _ in 0..<20 {
        let starX = center.x - moonphaseWidth / 2 + CGFloat(generator.next()) * moonphaseWidth
        let starY = moonphaseY - moonphaseHeight / 2 + CGFloat(generator.next()) * moonphaseHeight
        let starSize = radius * 0.005 + CGFloat(generator.next()) * radius * 0.005
        
        let star = Path(ellipseIn: CGRect(
            x: starX - starSize,
            y: starY - starSize,
            width: starSize * 2,
            height: starSize * 2
        ))
        context.fill(star, with: .color(.white))
    }
    
    // Draw moon (full moon)
    let moonRadius = moonphaseHeight * 0.4
    let moonX = center.x
    
    let moon = Path(ellipseIn: CGRect(
        x: moonX - moonRadius,
        y: moonphaseY - moonRadius,
        width: moonRadius * 2,
        height: moonRadius * 2
    ))
    context.fill(moon, with: .color(moonColor))
    
    // Add craters to the moon
    let craters: [(CGFloat, CGFloat, CGFloat)] = [
        (0.3, 0.2, 0.1),
        (-0.2, -0.3, 0.15),
        (0.1, -0.1, 0.08)
    ]
    
    for (xOffset, yOffset, sizeRatio) in craters {
        let crater = Path(ellipseIn: CGRect(
            x: moonX + moonRadius * xOffset - moonRadius * sizeRatio,
            y: moonphaseY + moonRadius * yOffset - moonRadius * sizeRatio,
            width: moonRadius * sizeRatio * 2,
            height: moonRadius * sizeRatio * 2
        ))
        context.fill(crater, with: .color(moonColor.opacity(0.7)))
    }
    
    // Draw decorative frame around moonphase
    context.stroke(moonphaseRect, with: .color(clockBorderColor), lineWidth: 0.7)
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat, currentTime: Date, calendar: Calendar) {
    // Roman numerals
    let romanNumerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
    
    for i in 0..<12 {
        // Skip VI (6 o'clock) for moonphase
        if i == 5 { continue }
        
        let angle = Double.pi / 6 * Double(i) - Double.pi / 3
        let numberRadius = radius * 0.75
        
        context.draw(
            Text(romanNumerals[i])
                .font(.system(size: radius * 0.12))
                .foregroundColor(numbersColor),
            at: CGPoint(
                x: center.x + CGFloat(cos(angle)) * numberRadius,
                y: center.y + CGFloat(sin(angle)) * numberRadius
            )
        )
    }
    
    // Minute markers (small dots)
    for i in 0..<60 {
        if i % 5 == 0 { continue } // Skip where hour markers are
        
        let angle = Double.pi * 2 * Double(i) / 60
        let markerRadius: CGFloat = radius * 0.01
        
        let marker = Path(ellipseIn: CGRect(
            x: center.x + CGFloat(cos(angle)) * radius * 0.85 - markerRadius,
            y: center.y + CGFloat(sin(angle)) * radius * 0.85 - markerRadius,
            width: markerRadius * 2,
            height: markerRadius * 2
        ))
        context.fill(marker, with: .color(markersColor))
    }
    
    // Date window at 3 o'clock
    let dateX = center.x + radius * 0.6
    let dateY = center.y
    
    let dateWindow = Path(CGRect(
        x: dateX - radius * 0.08,
        y: dateY - radius * 0.06,
        width: radius * 0.16,
        height: radius * 0.12
    ))
    context.fill(dateWindow, with: .color(.white))
    context.stroke(dateWindow, with: .color(.black), lineWidth: 0.4)
    
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
    minuteAngle: Double,
    secondAngle: Double
) {
    var context = context
    
    // Hour hand - elegant leaf shape (blued steel)
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(hourAngle))
    
    var hourHandPath = Path()
    hourHandPath.move(to: CGPoint(x: 0, y: -radius * 0.5))
    hourHandPath.addQuadCurve(
        to: CGPoint(x: radius * 0.02, y: 0),
        control: CGPoint(x: radius * 0.04, y: -radius * 0.25)
    )
    hourHandPath.addQuadCurve(
        to: CGPoint(x: -radius * 0.02, y: 0),
        control: CGPoint(x: 0, y: radius * 0.1)
    )
    hourHandPath.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.5),
        control: CGPoint(x: -radius * 0.04, y: -radius * 0.25)
    )
    hourHandPath.closeSubpath()
    
    context.fill(hourHandPath, with: .color(hourHandColor))
    
    context.rotate(by: .degrees(-hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand - longer leaf shape
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(minuteAngle))
    
    var minuteHandPath = Path()
    minuteHandPath.move(to: CGPoint(x: 0, y: -radius * 0.7))
    minuteHandPath.addQuadCurve(
        to: CGPoint(x: radius * 0.015, y: 0),
        control: CGPoint(x: radius * 0.03, y: -radius * 0.35)
    )
    minuteHandPath.addQuadCurve(
        to: CGPoint(x: -radius * 0.015, y: 0),
        control: CGPoint(x: 0, y: radius * 0.1)
    )
    minuteHandPath.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.7),
        control: CGPoint(x: -radius * 0.03, y: -radius * 0.35)
    )
    minuteHandPath.closeSubpath()
    
    context.fill(minuteHandPath, with: .color(minuteHandColor))
    
    context.rotate(by: .degrees(-minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Second hand - thin with small counterbalance
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(secondAngle))
    
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.15))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.75))
    context.stroke(secondPath, with: .color(secondHandColor), style: StrokeStyle(lineWidth: 0.4, lineCap: .round))
    
    // Counterbalance
    let counterbalance = Path(ellipseIn: CGRect(
        x: -radius * 0.03,
        y: radius * 0.1 - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    context.fill(counterbalance, with: .color(secondHandColor))
    
    context.rotate(by: .degrees(-secondAngle))
    context.translateBy(x: -center.x, y: -center.y)
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

// MARK: - Seeded Random Number Generator

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
    
    mutating func next() -> Double {
        return Double(next() >> 11) * 0x1.0p-53
    }
}

// MARK: - Preview

struct LeonardAutomaticWatch_Previews: PreviewProvider {
    static var previews: some View {
        LeonardAutomaticWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
