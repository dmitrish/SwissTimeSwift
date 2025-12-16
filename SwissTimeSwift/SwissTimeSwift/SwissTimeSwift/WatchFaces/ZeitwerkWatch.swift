

import SwiftUI

struct ZeitwerkWatch: View {
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

private let clockFaceColor = Color(red: 0x1A/255.0, green: 0x3A/255.0, blue: 0x5A/255.0) // Deep Atlantic blue dial
private let clockBorderColor = Color(red: 0xD0/255.0, green: 0xD0/255.0, blue: 0xD0/255.0) // Silver stainless steel border
private let hourHandColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0) // Silver hour hand
private let minuteHandColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0) // Silver minute hand
private let secondHandColor = Color(red: 0xE6/255.0, green: 0x39/255.0, blue: 0x46/255.0) // Red second hand
private let markersColor = Color.white // White markers
private let lumeColor = Color(red: 0x90/255.0, green: 0xEE/255.0, blue: 0x90/255.0) // Light green lume
private let centerDotColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0) // Silver center dot

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat, currentTime: Date) {
    // Outer circle (border) - stainless steel case
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: 8)
    
    // Inner circle (face) - Atlantic blue dial
    let innerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.95,
        y: center.y - radius * 0.95,
        width: radius * 1.9,
        height: radius * 1.9
    ))
    context.fill(innerCircle, with: .color(clockFaceColor))
    
    // Draw "Zeitwerk" logo
    context.draw(
        Text("Zeitwerk")
            .font(.system(size: radius * 0.12, weight: .bold))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y - radius * 0.15)
    )
    
    // Draw "Alpenglühen" text
    context.draw(
        Text("Alpenglühen")
            .font(.system(size: radius * 0.06))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y - radius * 0.05)
    )
    
    // Draw "ZEIT" text
    context.draw(
        Text("ZEIT")
            .font(.system(size: radius * 0.08))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y + radius * 0.6)
    )
    
    // Draw "AUTOMATIC" text
    context.draw(
        Text("AUTOMATIC")
            .font(.system(size: radius * 0.06))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y + radius * 0.8)
    )
    
    // Draw date window at 6 o'clock
    let dateAngle = Double.pi * 1.5 // 6 o'clock
    let dateX = center.x + CGFloat(cos(dateAngle)) * radius * 0.7
    let dateY = center.y + CGFloat(sin(dateAngle)) * radius * 0.7
    
    // Date window - rectangular with rounded corners
    let dateWindow = Path(roundedRect: CGRect(
        x: dateX - radius * 0.08,
        y: dateY - radius * 0.06,
        width: radius * 0.16,
        height: radius * 0.12
    ), cornerRadius: radius * 0.01)
    
    context.fill(dateWindow, with: .color(.white))
    
    // Date text
    let calendar = Calendar.current
    let day = calendar.component(.day, from: currentTime)
    
    context.draw(
        Text("\(day)")
            .font(.system(size: radius * 0.08, weight: .bold))
            .foregroundColor(.black),
        at: CGPoint(x: dateX, y: dateY)
    )
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw hour markers
    for i in 0..<12 {
        let angle = Double.pi / 6 * Double(i)
        
        // Skip 6 o'clock where the date window is
        if i == 6 { continue }
        
        let markerLength = (i % 3 == 0) ? radius * 0.1 : radius * 0.05 // Longer at 12, 3, 9
        let markerWidth = (i % 3 == 0) ? radius * 0.02 : radius * 0.01 // Thicker at 12, 3, 9
        
        let outerX = center.x + CGFloat(cos(angle)) * radius * 0.85
        let outerY = center.y + CGFloat(sin(angle)) * radius * 0.85
        let innerX = center.x + CGFloat(cos(angle)) * (radius * 0.85 - markerLength)
        let innerY = center.y + CGFloat(sin(angle)) * (radius * 0.85 - markerLength)
        
        // Draw hour marker
        var markerPath = Path()
        markerPath.move(to: CGPoint(x: innerX, y: innerY))
        markerPath.addLine(to: CGPoint(x: outerX, y: outerY))
        
        context.stroke(
            markerPath,
            with: .color(markersColor),
            style: StrokeStyle(lineWidth: markerWidth, lineCap: .round)
        )
        
        // Add lume dot at the end of the marker
        if i % 3 == 0 {
            let lumeDot = Path(ellipseIn: CGRect(
                x: outerX - markerWidth * 0.8,
                y: outerY - markerWidth * 0.8,
                width: markerWidth * 1.6,
                height: markerWidth * 1.6
            ))
            context.fill(lumeDot, with: .color(lumeColor))
        }
    }
    
    // Draw minute markers (smaller lines)
    for i in 0..<60 {
        // Skip positions where hour markers are
        if i % 5 == 0 { continue }
        
        let angle = Double.pi * 2 * Double(i) / 60
        let markerLength = radius * 0.02
        
        let outerX = center.x + CGFloat(cos(angle)) * radius * 0.85
        let outerY = center.y + CGFloat(sin(angle)) * radius * 0.85
        let innerX = center.x + CGFloat(cos(angle)) * (radius * 0.85 - markerLength)
        let innerY = center.y + CGFloat(sin(angle)) * (radius * 0.85 - markerLength)
        
        // Draw minute marker
        var minutePath = Path()
        minutePath.move(to: CGPoint(x: innerX, y: innerY))
        minutePath.addLine(to: CGPoint(x: outerX, y: outerY))
        
        context.stroke(
            minutePath,
            with: .color(markersColor),
            style: StrokeStyle(lineWidth: radius * 0.005, lineCap: .round)
        )
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
    
    // Hour hand - straight with lume
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(hourAngle))
    
    // Main hour hand - straight and thin
    let hourHand = Path(roundedRect: CGRect(
        x: -radius * 0.02,
        y: -radius * 0.5,
        width: radius * 0.04,
        height: radius * 0.5
    ), cornerRadius: radius * 0.01)
    context.fill(hourHand, with: .color(hourHandColor))
    
    // Lume on hour hand tip
    let hourLume = Path(ellipseIn: CGRect(
        x: -radius * 0.03,
        y: -radius * 0.45 - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    context.fill(hourLume, with: .color(lumeColor))
    
    context.rotate(by: .degrees(-hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand - longer and thinner
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(minuteAngle))
    
    // Main minute hand - straight and thin
    let minuteHand = Path(roundedRect: CGRect(
        x: -radius * 0.015,
        y: -radius * 0.7,
        width: radius * 0.03,
        height: radius * 0.7
    ), cornerRadius: radius * 0.01)
    context.fill(minuteHand, with: .color(minuteHandColor))
    
    // Lume on minute hand tip
    let minuteLume = Path(ellipseIn: CGRect(
        x: -radius * 0.025,
        y: -radius * 0.65 - radius * 0.025,
        width: radius * 0.05,
        height: radius * 0.05
    ))
    context.fill(minuteLume, with: .color(lumeColor))
    
    context.rotate(by: .degrees(-minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Second hand - thin red with distinctive circle near tip
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(secondAngle))
    
    // Main second hand
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.15))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.75))
    context.stroke(
        secondPath,
        with: .color(secondHandColor),
        style: StrokeStyle(lineWidth: 2, lineCap: .round)
    )
    
    // Distinctive circle near tip
    let secondCircle = Path(ellipseIn: CGRect(
        x: -radius * 0.03,
        y: -radius * 0.65 - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))
    context.fill(secondCircle, with: .color(secondHandColor))
    
    // Counterbalance
    let counterbalance = Path(ellipseIn: CGRect(
        x: -radius * 0.02,
        y: radius * 0.1 - radius * 0.02,
        width: radius * 0.04,
        height: radius * 0.04
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

struct ZeitwerkWatch_Previews: PreviewProvider {
    static var previews: some View {
        ZeitwerkWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
