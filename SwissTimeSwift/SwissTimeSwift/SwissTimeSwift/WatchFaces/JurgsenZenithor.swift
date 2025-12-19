
import SwiftUI

struct JurgsenZenithor: View {
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
                    drawHourMarkersAndNumbers(context: context, center: center, radius: radius)
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

// MARK: - Colors (cleaner dive-inspired look)

private let clockFaceColor = Color.black                                    // Deep black dial
private let bezelColor = Color(red: 0.0, green: 0.0, blue: 0.502)           // Navy blue — outer border only
private let hourHandColor = Color.white                                      // White hour hand
private let minuteHandColor = Color.white                                    // White minute hand
private let secondHandColor = Color(red: 1.0, green: 0.271, blue: 0.0)       // Orange-red second hand
private let markersColor = Color.white                                       // White markers
private let lumeColor = Color(red: 0.565, green: 0.933, blue: 0.565)         // Light green lume
private let centerDotColor = Color.white                                     // White center dot

// MARK: - Border width (points)
private let outerBorderWidth: CGFloat = 4 // 4pt

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Inside edge of the outer stroke
    let faceRadius = radius - outerBorderWidth / 2

    // 1) Draw the dial first so the border sits on top — eliminates any gap
    let dialRadius = faceRadius // no inset
    let dial = Path(ellipseIn: CGRect(
        x: center.x - dialRadius,
        y: center.y - dialRadius,
        width: dialRadius * 2,
        height: dialRadius * 2
    ))
    context.fill(dial, with: .color(clockFaceColor))

    // 2) Thin outer border (blue) drawn last
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(bezelColor), lineWidth: outerBorderWidth)

    // Branding text, scaled to the expanded inner radius
    context.draw(
        Text("Zénithor")
            .font(.system(size: dialRadius * 0.14, weight: .bold))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y - dialRadius * 0.34)
    )

    context.draw(
        Text("JÜRGSEN GENÈVE")
            .font(.system(size: dialRadius * 0.095, weight: .regular))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y + dialRadius * 0.34)
    )
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Base all geometry from the expanded dial (no inset)
    let faceRadius = radius - outerBorderWidth / 2
    let dialRadius = faceRadius

    // Move the marker ring outward to occupy more of the dial
    let markerRingRadius = dialRadius * 0.8

    // Large, luminous hour markers
    for i in 1...12 {
        let angle = Double.pi / 6 * Double(i - 3)

        let markerRadius = (i % 3 == 0) ? dialRadius * 0.065 : dialRadius * 0.055
        let markerX = center.x + CGFloat(cos(angle)) * markerRingRadius
        let markerY = center.y + CGFloat(sin(angle)) * markerRingRadius

        // White outer circle
        let outerMarker = Path(ellipseIn: CGRect(
            x: markerX - markerRadius,
            y: markerY - markerRadius,
            width: markerRadius * 2,
            height: markerRadius * 2
        ))
        context.fill(outerMarker, with: .color(markersColor))

        // Lume inner circle
        let innerMarker = Path(ellipseIn: CGRect(
            x: markerX - markerRadius * 0.8,
            y: markerY - markerRadius * 0.8,
            width: markerRadius * 1.6,
            height: markerRadius * 1.6
        ))
        context.fill(innerMarker, with: .color(lumeColor))

        // Special rectangular marker at 12 o'clock
        if i == 12 {
            let rectSize = dialRadius * 0.13
            let rectInset = dialRadius * 0.065
            let rect12 = Path(roundedRect: CGRect(
                x: center.x - rectInset,
                y: center.y - markerRingRadius - rectInset,
                width: rectSize,
                height: rectSize
            ), cornerRadius: 0)
            context.fill(rect12, with: .color(markersColor))

            // Lume inside
            let lumeSize = dialRadius * 0.11
            let lumeInset = dialRadius * 0.055
            let lumeRect = Path(roundedRect: CGRect(
                x: center.x - lumeInset,
                y: center.y - markerRingRadius - lumeInset,
                width: lumeSize,
                height: lumeSize
            ), cornerRadius: 0)
            context.fill(lumeRect, with: .color(lumeColor))
        }
    }

    // Date window at ~4:30 position, pushed outward slightly
    let dateAngle = Double.pi / 6 * 4.5
    let dateRingRadius = dialRadius * 0.6
    let dateX = center.x + CGFloat(cos(dateAngle)) * dateRingRadius
    let dateY = center.y + CGFloat(sin(dateAngle)) * dateRingRadius

    let dateW = dialRadius * 0.18
    let dateH = dialRadius * 0.135
    let dateWindow = Path(roundedRect: CGRect(
        x: dateX - dateW / 2,
        y: dateY - dateH / 2,
        width: dateW,
        height: dateH
    ), cornerRadius: 2)
    context.fill(dateWindow, with: .color(.white))

    // Date text
    let calendar = Calendar.current
    let day = calendar.component(.day, from: Date())

    let dateText = Text("\(day)")
        .font(.system(size: dialRadius * 0.11, weight: .bold))
        .foregroundColor(.black)

    context.draw(dateText, at: CGPoint(x: dateX, y: dateY))
}

private func drawClockHands(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    hourAngle: Double,
    minuteAngle: Double,
    secondAngle: Double
) {
    let faceRadius = radius - outerBorderWidth / 2
    let dialRadius = faceRadius // no inset

    // Hour hand - broad sword with lume
    var hourContext = context
    hourContext.translateBy(x: center.x, y: center.y)
    hourContext.rotate(by: .degrees(hourAngle))

    let hourHand = Path(roundedRect: CGRect(
        x: -dialRadius * 0.045,
        y: -dialRadius * 0.52,
        width: dialRadius * 0.09,
        height: dialRadius * 0.52
    ), cornerRadius: dialRadius * 0.022)
    hourContext.fill(hourHand, with: .color(hourHandColor))

    let hourLume = Path(roundedRect: CGRect(
        x: -dialRadius * 0.034,
        y: -dialRadius * 0.50,
        width: dialRadius * 0.068,
        height: dialRadius * 0.43
    ), cornerRadius: dialRadius * 0.016)
    hourContext.fill(hourLume, with: .color(lumeColor))

    // Minute hand - longer sword with lume
    var minuteContext = context
    minuteContext.translateBy(x: center.x, y: center.y)
    minuteContext.rotate(by: .degrees(minuteAngle))

    let minuteHand = Path(roundedRect: CGRect(
        x: -dialRadius * 0.034,
        y: -dialRadius * 0.75,
        width: dialRadius * 0.068,
        height: dialRadius * 0.75
    ), cornerRadius: dialRadius * 0.016)
    minuteContext.fill(minuteHand, with: .color(minuteHandColor))

    let minuteLume = Path(roundedRect: CGRect(
        x: -dialRadius * 0.024,
        y: -dialRadius * 0.72,
        width: dialRadius * 0.048,
        height: dialRadius * 0.64
    ), cornerRadius: dialRadius * 0.011)
    minuteContext.fill(minuteLume, with: .color(lumeColor))

    // Second hand - thin with circle near tip
    var secondContext = context
    secondContext.translateBy(x: center.x, y: center.y)
    secondContext.rotate(by: .degrees(secondAngle))

    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: dialRadius * 0.16))
    secondPath.addLine(to: CGPoint(x: 0, y: -dialRadius * 0.80))

    secondContext.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 2, lineCap: .round)
    )

    // Distinctive circle near tip
    let tipCircle = Path(ellipseIn: CGRect(
        x: -dialRadius * 0.042,
        y: -dialRadius * 0.64 - dialRadius * 0.042,
        width: dialRadius * 0.084,
        height: dialRadius * 0.084
    ))
    secondContext.fill(tipCircle, with: .color(secondHandColor))

    // Counterbalance
    let counterbalance = Path(ellipseIn: CGRect(
        x: -dialRadius * 0.032,
        y: dialRadius * 0.11 - dialRadius * 0.032,
        width: dialRadius * 0.064,
        height: dialRadius * 0.064
    ))
    secondContext.fill(counterbalance, with: .color(secondHandColor))
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let faceRadius = radius - outerBorderWidth / 2
    let dialRadius = faceRadius // no inset

    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - dialRadius * 0.042,
        y: center.y - dialRadius * 0.042,
        width: dialRadius * 0.084,
        height: dialRadius * 0.084
    ))
    context.fill(centerDot, with: .color(centerDotColor))
}

// MARK: - Preview

struct JurgsenZenithor_Previews: PreviewProvider {
    static var previews: some View {
        JurgsenZenithor()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
