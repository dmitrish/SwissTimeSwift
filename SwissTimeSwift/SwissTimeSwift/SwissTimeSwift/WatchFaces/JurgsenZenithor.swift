


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

// MARK: - Colors (inspired by dive watches)

private let clockFaceColor = Color.black                                    // Deep black dial
private let clockBorderColor = Color(red: 0.188, green: 0.188, blue: 0.188) // Dark gray border
private let bezelColor = Color(red: 0.0, green: 0.0, blue: 0.502)          // Navy blue bezel
private let bezelMarkersColor = Color.white                                  // White bezel markers
private let hourHandColor = Color.white                                      // White hour hand
private let minuteHandColor = Color.white                                    // White minute hand
private let secondHandColor = Color(red: 1.0, green: 0.271, blue: 0.0)     // Orange-red second hand
private let markersColor = Color.white                                       // White markers
private let lumeColor = Color(red: 0.565, green: 0.933, blue: 0.565)       // Light green lume
private let centerDotColor = Color.white                                     // White center dot

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw outer circle (border)
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: 8)
    
    // Draw rotating bezel (characteristic of dive watches)
    let bezelCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.95,
        y: center.y - radius * 0.95,
        width: radius * 1.9,
        height: radius * 1.9
    ))
    context.fill(bezelCircle, with: .color(bezelColor))
    
    // Draw bezel markers (minute markers for diving)
    for i in 0..<60 {
        let angle = Double.pi * 2 * Double(i) / 60
        
        if i % 5 == 0 {
            // Draw larger markers at 5-minute intervals
            let markerLength = (i == 0) ? radius * 0.08 : radius * 0.06
            let markerEnd = radius * 0.95
            
            let endX = center.x + CGFloat(cos(angle)) * markerEnd
            let endY = center.y + CGFloat(sin(angle)) * markerEnd
            
            // Draw triangle at 12 o'clock (0 minutes)
            if i == 0 {
                let lumeMarker = Path(ellipseIn: CGRect(
                    x: endX - radius * 0.03,
                    y: endY - radius * 0.03,
                    width: radius * 0.06,
                    height: radius * 0.06
                ))
                context.fill(lumeMarker, with: .color(lumeColor))
            } else {
                // Draw dot markers for other 5-minute intervals
                let dotMarker = Path(ellipseIn: CGRect(
                    x: endX - radius * 0.02,
                    y: endY - radius * 0.02,
                    width: radius * 0.04,
                    height: radius * 0.04
                ))
                context.fill(dotMarker, with: .color(bezelMarkersColor))
            }
        } else {
            // Draw smaller markers for minutes
            let dotX = center.x + CGFloat(cos(angle)) * radius * 0.95
            let dotY = center.y + CGFloat(sin(angle)) * radius * 0.95
            
            let smallDot = Path(ellipseIn: CGRect(
                x: dotX - radius * 0.005,
                y: dotY - radius * 0.005,
                width: radius * 0.01,
                height: radius * 0.01
            ))
            context.fill(smallDot, with: .color(bezelMarkersColor))
        }
    }
    
    // Draw inner circle (face)
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.85,
        y: center.y - radius * 0.85,
        width: radius * 1.7,
        height: radius * 1.7
    ))
    context.fill(innerCircle, with: .color(clockFaceColor))
    
    // Draw logo text
    let logoText = Text("Zénithor")
        .font(.system(size: radius * 0.12, weight: .bold))
        .foregroundColor(.white)
    
    context.draw(logoText, at: CGPoint(x: center.x, y: center.y - radius * 0.3))
    
    // Draw "JÜRGSEN GENÈVE" text
    let modelText = Text("JÜRGSEN GENÈVE")
        .font(.system(size: radius * 0.08, weight: .regular))
        .foregroundColor(.white)
    
    context.draw(modelText, at: CGPoint(x: center.x, y: center.y + radius * 0.3))
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Large, luminous hour markers (dive watch style)
    for i in 1...12 {
        let angle = Double.pi / 6 * Double(i - 3)
        
        // Draw circular hour markers with lume
        let markerRadius = (i % 3 == 0) ? radius * 0.06 : radius * 0.05
        let markerX = center.x + CGFloat(cos(angle)) * radius * 0.7
        let markerY = center.y + CGFloat(sin(angle)) * radius * 0.7
        
        // White outer circle
        let outerMarker = Path(ellipseIn: CGRect(
            x: markerX - markerRadius,
            y: markerY - markerRadius,
            width: markerRadius * 2,
            height: markerRadius * 2
        ))
        context.fill(outerMarker, with: .color(markersColor))
        
        // Lume inner circle (slightly smaller)
        let innerMarker = Path(ellipseIn: CGRect(
            x: markerX - markerRadius * 0.8,
            y: markerY - markerRadius * 0.8,
            width: markerRadius * 1.6,
            height: markerRadius * 1.6
        ))
        context.fill(innerMarker, with: .color(lumeColor))
        
        // Special rectangular marker at 12 o'clock
        if i == 12 {
            let rect12 = Path(roundedRect: CGRect(
                x: center.x - radius * 0.06,
                y: center.y - radius * 0.7 - radius * 0.06,
                width: radius * 0.12,
                height: radius * 0.12
            ), cornerRadius: 0)
            context.fill(rect12, with: .color(markersColor))
            
            // Lume inside
            let lumeRect = Path(roundedRect: CGRect(
                x: center.x - radius * 0.05,
                y: center.y - radius * 0.7 - radius * 0.05,
                width: radius * 0.1,
                height: radius * 0.1
            ), cornerRadius: 0)
            context.fill(lumeRect, with: .color(lumeColor))
        }
    }
    
    // Draw date window at 4:30 position
    let dateAngle = Double.pi / 6 * 4.5 // Between 4 and 5
    let dateX = center.x + CGFloat(cos(dateAngle)) * radius * 0.55
    let dateY = center.y + CGFloat(sin(dateAngle)) * radius * 0.55
    
    // White date window
    let dateWindow = Path(roundedRect: CGRect(
        x: dateX - radius * 0.08,
        y: dateY - radius * 0.06,
        width: radius * 0.16,
        height: radius * 0.12
    ), cornerRadius: 2)
    context.fill(dateWindow, with: .color(.white))
    
    // Date text
    let calendar = Calendar.current
    let day = calendar.component(.day, from: Date())
    
    let dateText = Text("\(day)")
        .font(.system(size: radius * 0.1, weight: .bold))
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
    // Hour hand - broad sword-shaped with lume
    var hourContext = context
    hourContext.translateBy(x: center.x, y: center.y)
    hourContext.rotate(by: .degrees(hourAngle))
    
    // Main hour hand
    let hourHand = Path(roundedRect: CGRect(
        x: -radius * 0.04,
        y: -radius * 0.5,
        width: radius * 0.08,
        height: radius * 0.5
    ), cornerRadius: radius * 0.02)
    hourContext.fill(hourHand, with: .color(hourHandColor))
    
    // Lume on hour hand
    let hourLume = Path(roundedRect: CGRect(
        x: -radius * 0.03,
        y: -radius * 0.48,
        width: radius * 0.06,
        height: radius * 0.4
    ), cornerRadius: radius * 0.015)
    hourContext.fill(hourLume, with: .color(lumeColor))
    
    // Minute hand - longer sword-shaped with lume
    var minuteContext = context
    minuteContext.translateBy(x: center.x, y: center.y)
    minuteContext.rotate(by: .degrees(minuteAngle))
    
    // Main minute hand
    let minuteHand = Path(roundedRect: CGRect(
        x: -radius * 0.03,
        y: -radius * 0.7,
        width: radius * 0.06,
        height: radius * 0.7
    ), cornerRadius: radius * 0.015)
    minuteContext.fill(minuteHand, with: .color(minuteHandColor))
    
    // Lume on minute hand
    let minuteLume = Path(roundedRect: CGRect(
        x: -radius * 0.02,
        y: -radius * 0.68,
        width: radius * 0.04,
        height: radius * 0.6
    ), cornerRadius: radius * 0.01)
    minuteContext.fill(minuteLume, with: .color(lumeColor))
    
    // Second hand - thin with distinctive circle near tip
    var secondContext = context
    secondContext.translateBy(x: center.x, y: center.y)
    secondContext.rotate(by: .degrees(secondAngle))
    
    // Main second hand
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.15))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.75))
    
    secondContext.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 2, lineCap: .round)
    )
    
    // Distinctive circle near tip
    let tipCircle = Path(ellipseIn: CGRect(
        x: -radius * 0.04,
        y: -radius * 0.6 - radius * 0.04,
        width: radius * 0.08,
        height: radius * 0.08
    ))
    secondContext.fill(tipCircle, with: .color(secondHandColor))
    
    // Counterbalance
    let counterbalance = Path(ellipseIn: CGRect(
        x: -radius * 0.03,
        y: radius * 0.1 - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    secondContext.fill(counterbalance, with: .color(secondHandColor))
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let centerDot = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.04,
        y: center.y - radius * 0.04,
        width: radius * 0.08,
        height: radius * 0.08
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
