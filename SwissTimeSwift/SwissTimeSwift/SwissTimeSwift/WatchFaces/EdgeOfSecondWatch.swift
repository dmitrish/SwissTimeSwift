

import SwiftUI

struct EdgeOfSecondWatch: View {
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
                    drawMinuteTrack(context: context, center: center, radius: radius)
                    drawHourMarkersAndNumbers(context: context, center: center, radius: radius)
                    drawSubdials(context: context, center: center, radius: radius)
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
                        minuteAngle: minuteAngle
                    )
                    
                    drawSmallSecondsHand(
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

// MARK: - Colors (Edge of Second inspired)

private let clockFaceColor = Color(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0) // Silver-white dial
private let clockBorderColor = Color(red: 0xD4/255.0, green: 0xAF/255.0, blue: 0x37/255.0) // Gold case
private let hourHandColor = Color.black
private let minuteHandColor = Color.black
private let secondHandColor = Color(red: 0x8B/255.0, green: 0x00/255.0, blue: 0x00/255.0) // Dark red
private let markersColor = Color(red: 0xD4/255.0, green: 0xAF/255.0, blue: 0x37/255.0) // Gold markers
private let numbersColor = Color.black
private let subdialBorderColor = Color(red: 0xD4/255.0, green: 0xAF/255.0, blue: 0x37/255.0) // Gold
private let subdialColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0) // Light gray
private let logoColor = Color.black

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Outer circle (case)
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: 8)
    
    // Inner circle (face)
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - (radius - 4),
        y: center.y - (radius - 4),
        width: (radius - 4) * 2,
        height: (radius - 4) * 2
    ))
    context.fill(innerCircle, with: .color(clockFaceColor))
}

private func drawMinuteTrack(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Railway track minute scale
    let trackRadius = radius * 0.9
    let innerTrackRadius = radius * 0.85
    
    // Outer and inner circles of the track
    let outerTrack = Path(ellipseIn: CGRect(
        x: center.x - trackRadius,
        y: center.y - trackRadius,
        width: trackRadius * 2,
        height: trackRadius * 2
    ))
    context.stroke(outerTrack, with: .color(.black), lineWidth: 1)
    
    let innerTrack = Path(ellipseIn: CGRect(
        x: center.x - innerTrackRadius,
        y: center.y - innerTrackRadius,
        width: innerTrackRadius * 2,
        height: innerTrackRadius * 2
    ))
    context.stroke(innerTrack, with: .color(.black), lineWidth: 1)
    
    // Minute markers
    for i in 0..<60 {
        let angle = 2 * Double.pi * Double(i) / 60
        let isHourMarker = i % 5 == 0
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * innerTrackRadius,
            y: center.y + CGFloat(sin(angle)) * innerTrackRadius
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * trackRadius,
            y: center.y + CGFloat(sin(angle)) * trackRadius
        ))
        
        context.stroke(
            path,
            with: .color(.black),
            lineWidth: isHourMarker ? 1.5 : 0.5
        )
    }
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Applied gold indices (skip positions where subdials are: 3, 6, 9)
    for i in 0..<12 {
        if i == 3 || i == 6 || i == 9 { continue }
        
        let angle = Double.pi / 6 * Double(i)
        let markerLength = radius * 0.08
        
        var path = Path()
        path.move(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * (radius * 0.75),
            y: center.y + CGFloat(sin(angle)) * (radius * 0.75)
        ))
        path.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(angle)) * (radius * 0.75 - markerLength),
            y: center.y + CGFloat(sin(angle)) * (radius * 0.75 - markerLength)
        ))
        
        context.stroke(
            path,
            with: .color(markersColor),
            style: StrokeStyle(lineWidth: 3, lineCap: .round)
        )
    }
    
    // Roman numeral "XII" at 12 o'clock
    context.draw(
        Text("XII")
            .font(.system(size: radius * 0.12, weight: .bold))
            .foregroundColor(numbersColor),
        at: CGPoint(x: center.x, y: center.y - radius * 0.6)
    )
}

private func drawSubdials(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Power reserve indicator at 3 o'clock
    let powerReserveCenter = CGPoint(x: center.x + radius * 0.5, y: center.y)
    let powerReserveRadius = radius * 0.15
    
    let powerReserveDial = Path(ellipseIn: CGRect(
        x: powerReserveCenter.x - powerReserveRadius,
        y: powerReserveCenter.y - powerReserveRadius,
        width: powerReserveRadius * 2,
        height: powerReserveRadius * 2
    ))
    context.fill(powerReserveDial, with: .color(subdialColor))
    context.stroke(powerReserveDial, with: .color(subdialBorderColor), lineWidth: 2)
    
    // Power reserve text
    context.draw(
        Text("Пламя")
            .font(.system(size: powerReserveRadius * 0.4))
            .foregroundColor(.black),
        at: CGPoint(x: powerReserveCenter.x, y: powerReserveCenter.y - powerReserveRadius * 0.3)
    )
    
    context.draw(
        Text("Лёд")
            .font(.system(size: powerReserveRadius * 0.4))
            .foregroundColor(.black),
        at: CGPoint(x: powerReserveCenter.x, y: powerReserveCenter.y + powerReserveRadius * 0.5)
    )
    
    // Power reserve indicator hand (fixed at 180° for display)
    var powerContext = context
    powerContext.translateBy(x: powerReserveCenter.x, y: powerReserveCenter.y)
    powerContext.rotate(by: .degrees(180))
    
    var powerHand = Path()
    powerHand.move(to: .zero)
    powerHand.addLine(to: CGPoint(x: 0, y: -powerReserveRadius * 0.8))
    
    powerContext.stroke(
        powerHand,
        with: .color(.black),
        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
    )
    
    // Small seconds subdial at 9 o'clock
    let smallSecondsCenter = CGPoint(x: center.x - radius * 0.5, y: center.y)
    let smallSecondsRadius = radius * 0.15
    
    let secondsDial = Path(ellipseIn: CGRect(
        x: smallSecondsCenter.x - smallSecondsRadius,
        y: smallSecondsCenter.y - smallSecondsRadius,
        width: smallSecondsRadius * 2,
        height: smallSecondsRadius * 2
    ))
    context.fill(secondsDial, with: .color(subdialColor))
    context.stroke(secondsDial, with: .color(subdialBorderColor), lineWidth: 2)
    
    // Small seconds markers
    for i in 0..<60 {
        let angle = 2 * Double.pi * Double(i) / 60
        let isQuarterMarker = i % 15 == 0
        let isFiveSecondMarker = i % 5 == 0
        
        let markerLength: CGFloat
        if isQuarterMarker {
            markerLength = smallSecondsRadius * 0.3
        } else if isFiveSecondMarker {
            markerLength = smallSecondsRadius * 0.2
        } else {
            markerLength = smallSecondsRadius * 0.1
        }
        
        var path = Path()
        path.move(to: CGPoint(
            x: smallSecondsCenter.x + CGFloat(cos(angle)) * (smallSecondsRadius - markerLength),
            y: smallSecondsCenter.y + CGFloat(sin(angle)) * (smallSecondsRadius - markerLength)
        ))
        path.addLine(to: CGPoint(
            x: smallSecondsCenter.x + CGFloat(cos(angle)) * smallSecondsRadius * 0.9,
            y: smallSecondsCenter.y + CGFloat(sin(angle)) * smallSecondsRadius * 0.9
        ))
        
        context.stroke(
            path,
            with: .color(.black),
            lineWidth: isQuarterMarker ? 1.5 : 0.5
        )
    }
    
    // Date subdial at 6 o'clock
    let dateCenter = CGPoint(x: center.x, y: center.y + radius * 0.5)
    let dateRadius = radius * 0.15
    
    let dateDial = Path(ellipseIn: CGRect(
        x: dateCenter.x - dateRadius,
        y: dateCenter.y - dateRadius,
        width: dateRadius * 2,
        height: dateRadius * 2
    ))
    context.fill(dateDial, with: .color(subdialColor))
    context.stroke(dateDial, with: .color(subdialBorderColor), lineWidth: 2)
    
    context.draw(
        Text("DATE")
            .font(.system(size: dateRadius * 0.4))
            .foregroundColor(.black),
        at: CGPoint(x: dateCenter.x, y: dateCenter.y)
    )
    
    context.draw(
        Text("15")
            .font(.system(size: dateRadius * 0.6, weight: .bold))
            .foregroundColor(.black),
        at: CGPoint(x: dateCenter.x, y: dateCenter.y + dateRadius * 0.5)
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
    
    // Hour hand - leaf-shaped
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(hourAngle))
    
    var hourPath = Path()
    hourPath.move(to: CGPoint(x: 0, y: -radius * 0.4))
    hourPath.addQuadCurve(
        to: CGPoint(x: radius * 0.015, y: 0),
        control: CGPoint(x: radius * 0.03, y: -radius * 0.2)
    )
    hourPath.addQuadCurve(
        to: CGPoint(x: -radius * 0.015, y: 0),
        control: CGPoint(x: 0, y: radius * 0.05)
    )
    hourPath.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.4),
        control: CGPoint(x: -radius * 0.03, y: -radius * 0.2)
    )
    hourPath.closeSubpath()
    
    context.fill(hourPath, with: .color(hourHandColor))
    
    context.rotate(by: .degrees(-hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand - longer leaf-shaped
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(minuteAngle))
    
    var minutePath = Path()
    minutePath.move(to: CGPoint(x: 0, y: -radius * 0.6))
    minutePath.addQuadCurve(
        to: CGPoint(x: radius * 0.01, y: 0),
        control: CGPoint(x: radius * 0.025, y: -radius * 0.3)
    )
    minutePath.addQuadCurve(
        to: CGPoint(x: -radius * 0.01, y: 0),
        control: CGPoint(x: 0, y: radius * 0.05)
    )
    minutePath.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.6),
        control: CGPoint(x: -radius * 0.025, y: -radius * 0.3)
    )
    minutePath.closeSubpath()
    
    context.fill(minutePath, with: .color(minuteHandColor))
    
    context.rotate(by: .degrees(-minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
}

private func drawSmallSecondsHand(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    secondAngle: Double
) {
    var context = context
    
    let smallSecondsCenter = CGPoint(x: center.x - radius * 0.5, y: center.y)
    let smallSecondsRadius = radius * 0.15
    
    context.translateBy(x: smallSecondsCenter.x, y: smallSecondsCenter.y)
    context.rotate(by: .degrees(secondAngle))
    
    var secondPath = Path()
    secondPath.move(to: .zero)
    secondPath.addLine(to: CGPoint(x: 0, y: -smallSecondsRadius * 0.8))
    
    context.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 1, lineCap: .round)
    )
    
    context.rotate(by: .degrees(-secondAngle))
    context.translateBy(x: -smallSecondsCenter.x, y: -smallSecondsCenter.y)
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    context.draw(
        Text("Грань Секунды")
            .font(.system(size: radius * 0.08, weight: .bold))
            .foregroundColor(logoColor),
        at: CGPoint(x: center.x, y: center.y - radius * 0.25)
    )
    
    context.draw(
        Text("Cosmos")
            .font(.system(size: radius * 0.06))
            .foregroundColor(logoColor),
        at: CGPoint(x: center.x, y: center.y - radius * 0.15)
    )
    
    context.draw(
        Text("Сделано в России")
            .font(.system(size: radius * 0.05))
            .foregroundColor(logoColor),
        at: CGPoint(x: center.x, y: center.y + radius * 0.15)
    )
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.02,
        y: center.y - radius * 0.02,
        width: radius * 0.04,
        height: radius * 0.04
    ))
    context.fill(centerDot, with: .color(clockBorderColor))
}

// MARK: - Preview

struct EdgeOfSecondWatch_Previews: PreviewProvider {
    static var previews: some View {
        EdgeOfSecondWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
