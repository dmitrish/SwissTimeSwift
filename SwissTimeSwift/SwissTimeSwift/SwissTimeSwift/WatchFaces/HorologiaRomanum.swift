

import SwiftUI

struct HorologiaRomanum: View {
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
                    drawStaticElements(context: context, center: center, radius: radius)
                    drawHourMarkersAndNumbers(context: context, center: center, radius: radius)
                    drawSubdialBackground(context: context, center: center, radius: radius)
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
                    
                    drawHourHand(context: context, center: center, radius: radius, angle: hourAngle)
                    drawMinuteHand(context: context, center: center, radius: radius, angle: minuteAngle)
                    drawSubdialSecondHand(context: context, center: center, radius: radius, angle: secondAngle)
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

private let clockFaceColor = Color(red: 0.961, green: 0.961, blue: 0.961)
private let clockBorderColor = Color(red: 0.188, green: 0.188, blue: 0.188)
private let hourHandColor = Color(red: 0.0, green: 0.0, blue: 0.502)
private let minuteHandColor = Color(red: 0.0, green: 0.0, blue: 0.502)
private let markersColor = Color.black
private let numbersColor = Color.black
private let subdialColor = Color(red: 0.878, green: 0.878, blue: 0.878)
private let subdialHandColor = Color(red: 0.0, green: 0.0, blue: 0.502)
private let centerDotColor = Color(red: 0.0, green: 0.0, blue: 0.502)

// MARK: - Drawing Functions

private func drawStaticElements(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw outer border
    let outerCircle = Path(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    context.stroke(outerCircle, with: .color(clockBorderColor), lineWidth: 6)
    
    // Draw main face
    let mainFace = Path(ellipseIn: CGRect(
        x: center.x - (radius - 3),
        y: center.y - (radius - 3),
        width: (radius - 3) * 2,
        height: (radius - 3) * 2
    ))
    context.fill(mainFace, with: .color(clockFaceColor))
    
    // Draw logo "HOROLOGIA"
    let logoText = Text("HOROLOGIA")
        .font(.system(size: radius * 0.12, weight: .bold))
        .foregroundColor(.black)
    
    context.draw(logoText, at: CGPoint(x: center.x, y: center.y - radius * 0.3))
    
    // Draw origin text "ROMANUM"
    let originText = Text("ROMANUM")
        .font(.system(size: radius * 0.06, weight: .regular))
        .foregroundColor(.black)
    
    context.draw(originText, at: CGPoint(x: center.x, y: center.y - radius * 0.2))
}

private func drawSubdialBackground(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let subdialCenter = CGPoint(x: center.x, y: center.y + radius * 0.4)
    let subdialRadius = radius * 0.2
    
    // Draw subdial face
    let subdialFace = Path(ellipseIn: CGRect(
        x: subdialCenter.x - subdialRadius,
        y: subdialCenter.y - subdialRadius,
        width: subdialRadius * 2,
        height: subdialRadius * 2
    ))
    context.fill(subdialFace, with: .color(subdialColor))
    
    // Draw subdial border
    context.stroke(subdialFace, with: .color(.black), lineWidth: 2)
    
    // Draw subdial markers
    for i in 0..<60 {
        let angle = Double.pi * 2 * Double(i) / 60
        let markerLength: CGFloat
        if i % 15 == 0 {
            markerLength = subdialRadius * 0.2
        } else if i % 5 == 0 {
            markerLength = subdialRadius * 0.15
        } else {
            markerLength = subdialRadius * 0.05
        }
        
        let startX = subdialCenter.x + CGFloat(cos(angle)) * (subdialRadius - markerLength)
        let startY = subdialCenter.y + CGFloat(sin(angle)) * (subdialRadius - markerLength)
        let endX = subdialCenter.x + CGFloat(cos(angle)) * subdialRadius * 0.9
        let endY = subdialCenter.y + CGFloat(sin(angle)) * subdialRadius * 0.9
        
        var path = Path()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        let strokeWidth: CGFloat = (i % 15 == 0) ? 1.5 : 1
        context.stroke(path, with: .color(.black), lineWidth: strokeWidth)
    }
    
    // Draw subdial numbers (60, 15, 30, 45)
    let secondsNumbers = ["60", "15", "30", "45"]
    
    for i in 0...3 {
        let angle = Double.pi / 2 * Double(i)
        let numberX = subdialCenter.x + CGFloat(cos(angle)) * subdialRadius * 0.6
        let numberY = subdialCenter.y + CGFloat(sin(angle)) * subdialRadius * 0.6
        
        let numberText = Text(secondsNumbers[i])
            .font(.system(size: subdialRadius * 0.3, weight: .regular))
            .foregroundColor(.black)
        
        context.draw(numberText, at: CGPoint(x: numberX, y: numberY))
    }
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Draw minute markers (skip subdial area)
    for i in 1...60 {
        let angle = Double.pi / 30 * Double(i - 15)
        let markerLength = (i % 5 == 0) ? radius * 0.05 : radius * 0.02
        let strokeWidth: CGFloat = (i % 5 == 0) ? 2 : 1
        
        // Skip markers in subdial area (bottom section)
        if i >= 25 && i <= 35 { continue }
        
        let startX = center.x + CGFloat(cos(angle)) * (radius - markerLength)
        let startY = center.y + CGFloat(sin(angle)) * (radius - markerLength)
        let endX = center.x + CGFloat(cos(angle)) * radius * 0.9
        let endY = center.y + CGFloat(sin(angle)) * radius * 0.9
        
        var path = Path()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        context.stroke(
            path,
            with: .color(markersColor),
            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
        )
    }
    
    // Draw hour numbers (skip 6 because of subdial)
    let hours = [12, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11]
    let positions = [0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11]
    
    for i in hours.indices {
        let angle = Double.pi / 6 * Double(positions[i]) - Double.pi / 2
        let numberRadius = radius * 0.75
        let numberX = center.x + CGFloat(cos(angle)) * numberRadius
        let numberY = center.y + CGFloat(sin(angle)) * numberRadius
        
        let numberText = Text("\(hours[i])")
            .font(.system(size: radius * 0.15, weight: .bold))
            .foregroundColor(numbersColor)
        
        context.draw(numberText, at: CGPoint(x: numberX, y: numberY))
    }
}

private func drawHourHand(context: GraphicsContext, center: CGPoint, radius: CGFloat, angle: Double) {
    var handContext = context
    handContext.translateBy(x: center.x, y: center.y)
    handContext.rotate(by: .degrees(angle))
    
    var path = Path()
    path.move(to: CGPoint(x: 0, y: -radius * 0.5))
    
    // Right side curve
    path.addQuadCurve(
        to: CGPoint(x: radius * 0.02, y: 0),
        control: CGPoint(x: radius * 0.04, y: -radius * 0.25)
    )
    
    // Bottom curve
    path.addQuadCurve(
        to: CGPoint(x: -radius * 0.02, y: 0),
        control: CGPoint(x: 0, y: radius * 0.1)
    )
    
    // Left side curve
    path.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.5),
        control: CGPoint(x: -radius * 0.04, y: -radius * 0.25)
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
        to: CGPoint(x: radius * 0.015, y: 0),
        control: CGPoint(x: radius * 0.03, y: -radius * 0.35)
    )
    
    // Bottom curve
    path.addQuadCurve(
        to: CGPoint(x: -radius * 0.015, y: 0),
        control: CGPoint(x: 0, y: radius * 0.1)
    )
    
    // Left side curve
    path.addQuadCurve(
        to: CGPoint(x: 0, y: -radius * 0.7),
        control: CGPoint(x: -radius * 0.03, y: -radius * 0.35)
    )
    
    path.closeSubpath()
    handContext.fill(path, with: .color(minuteHandColor))
}

private func drawSubdialSecondHand(context: GraphicsContext, center: CGPoint, radius: CGFloat, angle: Double) {
    let subdialCenter = CGPoint(x: center.x, y: center.y + radius * 0.4)
    let subdialRadius = radius * 0.2
    
    var handContext = context
    handContext.translateBy(x: subdialCenter.x, y: subdialCenter.y)
    handContext.rotate(by: .degrees(angle))
    
    // Main hand pointing up
    var mainPath = Path()
    mainPath.move(to: .zero)
    mainPath.addLine(to: CGPoint(x: 0, y: -subdialRadius * 0.8))
    
    handContext.stroke(
        mainPath,
        with: .color(subdialHandColor),
        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
    )
    
    // Counterbalance pointing down
    var counterPath = Path()
    counterPath.move(to: .zero)
    counterPath.addLine(to: CGPoint(x: 0, y: subdialRadius * 0.2))
    
    handContext.stroke(
        counterPath,
        with: .color(subdialHandColor),
        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
    )
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

struct HorologiaRomanum_Previews: PreviewProvider {
    static var previews: some View {
        HorologiaRomanum()
            .frame(width: 300, height: 300)
            .background(Color.black)
    }
}
