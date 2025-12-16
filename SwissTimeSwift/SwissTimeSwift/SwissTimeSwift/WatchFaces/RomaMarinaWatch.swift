


import SwiftUI

struct RomaMarinaWatch: View {
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

// MARK: - Colors (Roma Marina)

private let clockFaceColor = Color(red: 0x2F/255.0, green: 0x4F/255.0, blue: 0x4F/255.0) // Dark slate gray
private let clockBorderColor = Color(red: 0xC0/255.0, green: 0xC0/255.0, blue: 0xC0/255.0) // Silver
private let hourHandColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0) // Light silver
private let minuteHandColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0)
private let secondHandColor = Color(red: 0xFF/255.0, green: 0x45/255.0, blue: 0x00/255.0) // Orange-red
private let markersColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0)
private let numbersColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0)
private let centerDotColor = Color(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0)

// MARK: - Drawing Functions

private func drawClockFace(context: GraphicsContext, center: CGPoint, radius: CGFloat, currentTime: Date) {
    // Draw octagonal bezel
    var octagonPath = Path()
    for i in 0..<8 {
        let angle = Double.pi / 4 * Double(i)
        let x = center.x + CGFloat(cos(angle)) * radius
        let y = center.y + CGFloat(sin(angle)) * radius
        
        if i == 0 {
            octagonPath.move(to: CGPoint(x: x, y: y))
        } else {
            octagonPath.addLine(to: CGPoint(x: x, y: y))
        }
    }
    octagonPath.closeSubpath()
    
    context.fill(octagonPath, with: .color(clockBorderColor))
    
    // Draw inner octagonal face
    var innerOctagonPath = Path()
    let innerRadius = radius * 0.92
    for i in 0..<8 {
        let angle = Double.pi / 4 * Double(i)
        let x = center.x + CGFloat(cos(angle)) * innerRadius
        let y = center.y + CGFloat(sin(angle)) * innerRadius
        
        if i == 0 {
            innerOctagonPath.move(to: CGPoint(x: x, y: y))
        } else {
            innerOctagonPath.addLine(to: CGPoint(x: x, y: y))
        }
    }
    innerOctagonPath.closeSubpath()
    
    context.fill(innerOctagonPath, with: .color(clockFaceColor))
    
    // Draw hobnail pattern
    let patternRadius = radius * 0.8
    let gridSize = 12
    let squareSize = patternRadius * 2 / CGFloat(gridSize)
    
    for i in 0..<gridSize {
        for j in 0..<gridSize {
            let x = center.x - patternRadius + CGFloat(i) * squareSize
            let y = center.y - patternRadius + CGFloat(j) * squareSize
            
            // Skip squares outside the circle
            let dx = x + squareSize / 2 - center.x
            let dy = y + squareSize / 2 - center.y
            let distanceFromCenter = sqrt(dx * dx + dy * dy)
            if distanceFromCenter > patternRadius { continue }
            
            // Draw base square
            var pyramidPath = Path()
            pyramidPath.move(to: CGPoint(x: x, y: y))
            pyramidPath.addLine(to: CGPoint(x: x + squareSize, y: y))
            pyramidPath.addLine(to: CGPoint(x: x + squareSize, y: y + squareSize))
            pyramidPath.addLine(to: CGPoint(x: x, y: y + squareSize))
            pyramidPath.closeSubpath()
            
            context.fill(pyramidPath, with: .color(clockFaceColor.opacity(0.8)))
            
            // Draw highlight on top-left
            var highlightPath = Path()
            highlightPath.move(to: CGPoint(x: x, y: y))
            highlightPath.addLine(to: CGPoint(x: x + squareSize, y: y))
            highlightPath.addLine(to: CGPoint(x: x + squareSize / 2, y: y + squareSize / 2))
            highlightPath.closeSubpath()
            
            context.fill(highlightPath, with: .color(clockFaceColor.opacity(0.6)))
            
            // Draw shadow on bottom-right
            var shadowPath = Path()
            shadowPath.move(to: CGPoint(x: x + squareSize, y: y))
            shadowPath.addLine(to: CGPoint(x: x + squareSize, y: y + squareSize))
            shadowPath.addLine(to: CGPoint(x: x + squareSize / 2, y: y + squareSize / 2))
            shadowPath.closeSubpath()
            
            context.fill(shadowPath, with: .color(clockFaceColor))
        }
    }
    
    // Draw logo
    context.draw(
        Text("ROMA-MARINA")
            .font(.system(size: radius * 0.1, weight: .bold))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y - radius * 0.3)
    )
    
    // Draw model name
    context.draw(
        Text("MILITARE")
            .font(.system(size: radius * 0.07))
            .foregroundColor(.white),
        at: CGPoint(x: center.x, y: center.y - radius * 0.15)
    )
    
    // Draw date window at 3 o'clock
    let dateAngle = Double.pi / 2
    let dateX = center.x + CGFloat(cos(dateAngle)) * radius * 0.6
    let dateY = center.y + CGFloat(sin(dateAngle)) * radius * 0.6
    
    // Date window background
    let dateWindow = Path(CGRect(
        x: dateX - radius * 0.08,
        y: dateY - radius * 0.06,
        width: radius * 0.16,
        height: radius * 0.12
    ))
    context.fill(dateWindow, with: .color(.white))
    context.stroke(dateWindow, with: .color(.black), lineWidth: 1)
    
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
    let markerLength = radius * 0.1
    let markerWidth = radius * 0.02
    
    for i in 0..<12 {
        // Skip 3 o'clock where date window is
        if i == 3 { continue }
        
        let angle = Double.pi / 6 * Double(i)
        let markerX = center.x + CGFloat(cos(angle)) * radius * 0.7
        let markerY = center.y + CGFloat(sin(angle)) * radius * 0.7
        
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
        
        // Highlight for 3D effect
        let highlight = Path(CGRect(
            x: -markerWidth / 2 + 1,
            y: -markerLength / 2 + 1,
            width: markerWidth / 2,
            height: markerLength - 2
        ))
        markerContext.fill(highlight, with: .color(.white))
    }
    
    // Draw double marker at 12 o'clock
    let angle12 = Double.pi * 1.5
    let marker12X = center.x + CGFloat(cos(angle12)) * radius * 0.7
    let marker12Y = center.y + CGFloat(sin(angle12)) * radius * 0.7
    let markerGap = radius * 0.01
    
    // Left marker
    let leftMarker = Path(CGRect(
        x: marker12X - markerWidth * 1.5 - markerGap / 2,
        y: marker12Y - markerLength / 2,
        width: markerWidth,
        height: markerLength
    ))
    context.fill(leftMarker, with: .color(markersColor))
    
    // Right marker
    let rightMarker = Path(CGRect(
        x: marker12X + markerGap / 2,
        y: marker12Y - markerLength / 2,
        width: markerWidth,
        height: markerLength
    ))
    context.fill(rightMarker, with: .color(markersColor))
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
    
    // Hour hand - sword-shaped with center groove
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(hourAngle))
    
    var hourHandPath = Path()
    hourHandPath.move(to: CGPoint(x: 0, y: -radius * 0.5))
    hourHandPath.addLine(to: CGPoint(x: radius * 0.04, y: -radius * 0.2))
    hourHandPath.addLine(to: CGPoint(x: radius * 0.02, y: 0))
    hourHandPath.addLine(to: CGPoint(x: -radius * 0.02, y: 0))
    hourHandPath.addLine(to: CGPoint(x: -radius * 0.04, y: -radius * 0.2))
    hourHandPath.closeSubpath()
    
    context.fill(hourHandPath, with: .color(hourHandColor))
    
    // Center groove
    var hourGroove = Path()
    hourGroove.move(to: CGPoint(x: 0, y: -radius * 0.45))
    hourGroove.addLine(to: CGPoint(x: 0, y: -radius * 0.05))
    context.stroke(hourGroove, with: .color(clockFaceColor), lineWidth: 1)
    
    context.rotate(by: .degrees(-hourAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Minute hand - longer sword-shaped with center groove
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(minuteAngle))
    
    var minuteHandPath = Path()
    minuteHandPath.move(to: CGPoint(x: 0, y: -radius * 0.7))
    minuteHandPath.addLine(to: CGPoint(x: radius * 0.03, y: -radius * 0.2))
    minuteHandPath.addLine(to: CGPoint(x: radius * 0.015, y: 0))
    minuteHandPath.addLine(to: CGPoint(x: -radius * 0.015, y: 0))
    minuteHandPath.addLine(to: CGPoint(x: -radius * 0.03, y: -radius * 0.2))
    minuteHandPath.closeSubpath()
    
    context.fill(minuteHandPath, with: .color(minuteHandColor))
    
    // Center groove
    var minuteGroove = Path()
    minuteGroove.move(to: CGPoint(x: 0, y: -radius * 0.65))
    minuteGroove.addLine(to: CGPoint(x: 0, y: -radius * 0.05))
    context.stroke(minuteGroove, with: .color(clockFaceColor), lineWidth: 1)
    
    context.rotate(by: .degrees(-minuteAngle))
    context.translateBy(x: -center.x, y: -center.y)
    
    // Second hand - thin with arrow tip
    context.translateBy(x: center.x, y: center.y)
    context.rotate(by: .degrees(secondAngle))
    
    // Main second hand
    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: radius * 0.15))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.75))
    context.stroke(secondPath, with: .color(secondHandColor), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    
    // Arrow tip
    let arrowSize = radius * 0.04
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

struct RomaMarinaWatch_Previews: PreviewProvider {
    static var previews: some View {
        RomaMarinaWatch()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
