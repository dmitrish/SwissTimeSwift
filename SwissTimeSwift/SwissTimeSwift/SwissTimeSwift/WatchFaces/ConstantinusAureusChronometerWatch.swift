
import SwiftUI

struct ConstantinusAureusChronometerWatch: View {
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
                    drawClockFace(context: context, center: center, radius: radius, currentTime: currentTime)
                    drawHourMarkersAndNumbers(context: context, center: center, radius: radius)
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

// MARK: - Colors (Marine Chronometer inspired)

private let clockFaceColor = Color.white
private let clockBorderColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0) // Dark blue
private let hourHandColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)
private let minuteHandColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)
private let secondHandColor = Color(red: 0xB2/255.0, green: 0x22/255.0, blue: 0x22/255.0) // Red
private let markersColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)
private let numbersColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)
private let powerReserveColor = Color(red: 0xB2/255.0, green: 0x22/255.0, blue: 0x22/255.0)
private let centerDotColor = Color(red: 0x00/255.0, green: 0x00/255.0, blue: 0x8B/255.0)

// MARK: - Border width constant
private let outerBorderWidth: CGFloat = 2 // changed from 8 to 2

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat, currentTime: Date) {
    // Use a face radius that sits inside half the stroke width
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
    
    // Draw anchor symbol (Ulysse Nardin logo)
    let anchorSize = radius * 0.15
    let anchorY = center.y - radius * 0.3
    
    // Anchor stock (top horizontal bar)
    var stockPath = Path()
    stockPath.move(to: CGPoint(x: center.x - anchorSize / 2, y: anchorY - anchorSize / 4))
    stockPath.addLine(to: CGPoint(x: center.x + anchorSize / 2, y: anchorY - anchorSize / 4))
    context.stroke(stockPath, with: .color(clockBorderColor), lineWidth: anchorSize / 8)
    
    // Anchor stem (vertical bar)
    var stemPath = Path()
    stemPath.move(to: CGPoint(x: center.x, y: anchorY - anchorSize / 4))
    stemPath.addLine(to: CGPoint(x: center.x, y: anchorY + anchorSize / 2))
    context.stroke(stemPath, with: .color(clockBorderColor), lineWidth: anchorSize / 10)
    
    // Anchor arms
    let armWidth = anchorSize / 2
    let armHeight = anchorSize / 3
    
    // Left arm
    var leftArmPath = Path()
    leftArmPath.move(to: CGPoint(x: center.x, y: anchorY + anchorSize / 4))
    leftArmPath.addQuadCurve(
        to: CGPoint(x: center.x - armWidth, y: anchorY + armHeight),
        control: CGPoint(x: center.x - armWidth / 2, y: anchorY + anchorSize / 4)
    )
    context.stroke(leftArmPath, with: .color(clockBorderColor), lineWidth: anchorSize / 10)
    
    // Right arm
    var rightArmPath = Path()
    rightArmPath.move(to: CGPoint(x: center.x, y: anchorY + anchorSize / 4))
    rightArmPath.addQuadCurve(
        to: CGPoint(x: center.x + armWidth, y: anchorY + armHeight),
        control: CGPoint(x: center.x + armWidth / 2, y: anchorY + anchorSize / 4)
    )
    context.stroke(rightArmPath, with: .color(clockBorderColor), lineWidth: anchorSize / 10)
    
    // "CONSTANTINUS" text
    context.draw(
        Text("CONSTANTINUS")
            .font(.system(size: radius * 0.1, weight: .bold))
            .foregroundColor(clockBorderColor),
        at: CGPoint(x: center.x, y: center.y - radius * 0.1)
    )
    
    // "AUREUS CHRONOMETER" text
    context.draw(
        Text("AUREUS CHRONOMETER")
            .font(.system(size: radius * 0.06))
            .foregroundColor(clockBorderColor),
        at: CGPoint(x: center.x, y: center.y)
    )
    
    // Power reserve indicator at 12 o'clock
    let powerReserveY = center.y - radius * 0.5
    let powerReserveWidth = radius * 0.4
    let powerReserveHeight = radius * 0.1
    
    // Power reserve semi-circle background
    var powerReservePath = Path()
    powerReservePath.addArc(
        center: CGPoint(x: center.x, y: powerReserveY),
        radius: powerReserveWidth / 2,
        startAngle: .degrees(180),
        endAngle: .degrees(0),
        clockwise: false
    )
    context.stroke(powerReservePath, with: .color(.white), lineWidth: powerReserveHeight)
    context.stroke(powerReservePath, with: .color(clockBorderColor), lineWidth: 2)
    
    // Power reserve markings
   /* for i in 0...4 {
        let angle = Double.pi * Double(i) / 4
        let markerX = center.x + CGFloat(cos(angle + Double.pi)) * (powerReserveWidth / 2)
        let markerY = powerReserveY
        
        let marker = Path(ellipseIn: CGRect(
            x: markerX - 2,
            y: markerY - 2,
            width: 4,
            height: 4
        ))
        context.fill(marker, with: .color(clockBorderColor))
    } */
    
    // Power reserve text
    context.draw(
        Text("aurelius")
            .font(.system(size: powerReserveHeight * 0.5))
            .foregroundColor(clockBorderColor),
        at: CGPoint(x: center.x, y: powerReserveY - powerReserveHeight * 1.2)
    )
    
    // Power reserve indicator (60% full)
    var indicatorPath = Path()
    indicatorPath.addArc(
        center: CGPoint(x: center.x, y: powerReserveY),
        radius: powerReserveWidth / 2,
        startAngle: .degrees(180),
        endAngle: .degrees(180 + 180 * 0.6),
        clockwise: false
    )
    context.stroke(indicatorPath, with: .color(powerReserveColor), lineWidth: powerReserveHeight * 0.8)
    
    // Date window at 6 o'clock
    let dateY = center.y + radius * 0.5
    
    let dateWindow = Path(roundedRect: CGRect(
        x: center.x - radius * 0.15,
        y: dateY - radius * 0.08,
        width: radius * 0.3,
        height: radius * 0.16
    ), cornerRadius: radius * 0.02)
    
    context.fill(dateWindow, with: .color(.white))
    context.stroke(dateWindow, with: .color(clockBorderColor), lineWidth: 0.3)
    
    // Date text
    let calendar = Calendar.current
    let day = calendar.component(.day, from: currentTime)
    
    context.draw(
        Text("\(day)")
            .font(.system(size: radius * 0.1, weight: .bold))
            .foregroundColor(clockBorderColor),
        at: CGPoint(x: center.x, y: dateY)
    )
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Roman numerals
    let romanNumerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
    
    for i in 0..<12 {
        // Skip VI (6 o'clock) and XII (12 o'clock) for date window and power reserve
        if i == 5 || i == 11 { continue }
        
        let angle = Double.pi / 6 * Double(i) - Double.pi / 3
        let numberRadius = radius * 0.7
        
        context.draw(
            Text(romanNumerals[i])
                .font(.system(size: radius * 0.12, weight: .bold))
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
    
    // Railroad-style minute track divisions
    let trackRadius = radius * 0.85
    for i in 0..<60 {
        let angle = Double.pi * 2 * Double(i) / 60
        let trackWidth = radius * 0.03
        let innerRadius = trackRadius - trackWidth / 2
        let outerRadius = trackRadius + trackWidth / 2
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * innerRadius,
            y: center.y + CGFloat(sin(angle)) * innerRadius
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * outerRadius,
            y: center.y + CGFloat(sin(angle)) * outerRadius
        ))
        
        context.stroke(path, with: .color(markersColor.opacity(0.3)), lineWidth: 1)
    }
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
    
    // Hour hand - pear-shaped (marine chronometer style)
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
    
    // Minute hand - longer pear-shaped
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
    
    // Second hand - thin with arrow tip
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(secondAngle))
    
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.15))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.75))
    context.stroke(secondPath, with: .color(secondHandColor), style: StrokeStyle(lineWidth: 0.75, lineCap: .round))
    
    // Arrow tip
    let arrowSize = radius * 0.05
    var arrowPath = Path()
    arrowPath.move(to: CGPoint(x: 0, y: -radius * 0.75 - arrowSize))
    arrowPath.addLine(to: CGPoint(x: arrowSize / 2, y: -radius * 0.75))
    arrowPath.addLine(to: CGPoint(x: -arrowSize / 2, y: -radius * 0.75))
    arrowPath.closeSubpath()
    context.fill(arrowPath, with: .color(secondHandColor))
    
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

// MARK: - Preview

struct ConstantinusAureusChronometerWatch_Previews: PreviewProvider {
    static var previews: some View {
        ConstantinusAureusChronometerWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
