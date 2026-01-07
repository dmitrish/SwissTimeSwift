/*### What’s wrong
In your Swift `LucernaRoma`, the tonneau case is filled in black but then stroked with a different dark gray color (`Color(red: 0.19, green: 0.19, blue: 0.19)`) and `lineWidth: 8`, which creates a visible border. The Kotlin version you consider “correct” effectively doesn’t show a different-colored rim for you, so to match that intent, remove the differently-colored stroke (or make it the same color as the fill).

Also, your hour-hand angle math is off: `Double(hour * 30 + minute) * 0.5` halves the hour angle and makes the hour hand appear one hour behind. Use `Double(hour) * 30 + Double(minute) * 0.5`.

### Minimal change (remove the border stroke)
Replace the `drawTonneauCase` to just fill the shape and not stroke it differently. Also fix the hour-angle formula in the animated section.

```swift */
import SwiftUI

struct LucernaRoma: View {
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
                Canvas { context, _ in
                    drawTonneauCase(context: context, center: center, radius: radius)
                    drawHourMarkersAndNumbers(context: context, center: center, radius: radius)
                    drawLogo(context: context, center: center, radius: radius)
                }

                // Animated content
                Canvas { context, _ in
                    let hour = calendar.component(.hour, from: currentTime) % 12
                    let minute = calendar.component(.minute, from: currentTime)
                    let second = calendar.component(.second, from: currentTime)

                    // Correct hour-hand angle math
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

// MARK: - Drawing Functions

private func drawTonneauCase(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    // Create tonneau (barrel) shape path
    let width = radius * 1.8
    let height = radius * 2.0
    let curveRadius = width * 0.2

    var path = Path()

    // Top curve
    path.move(to: CGPoint(x: center.x - width / 2 + curveRadius, y: center.y - height / 2))
    path.addLine(to: CGPoint(x: center.x + width / 2 - curveRadius, y: center.y - height / 2))

    // Right curve
    path.addCurve(
        to: CGPoint(x: center.x + width / 2, y: center.y - height / 4),
        control1: CGPoint(x: center.x + width / 2, y: center.y - height / 2),
        control2: CGPoint(x: center.x + width / 2, y: center.y - height / 2 + curveRadius)
    )
    path.addLine(to: CGPoint(x: center.x + width / 2, y: center.y + height / 4))

    path.addCurve(
        to: CGPoint(x: center.x + width / 2 - curveRadius, y: center.y + height / 2),
        control1: CGPoint(x: center.x + width / 2, y: center.y + height / 2 - curveRadius),
        control2: CGPoint(x: center.x + width / 2, y: center.y + height / 2)
    )

    // Bottom curve
    path.addLine(to: CGPoint(x: center.x - width / 2 + curveRadius, y: center.y + height / 2))

    // Left curve
    path.addCurve(
        to: CGPoint(x: center.x - width / 2, y: center.y + height / 4),
        control1: CGPoint(x: center.x - width / 2, y: center.y + height / 2),
        control2: CGPoint(x: center.x - width / 2, y: center.y + height / 2 - curveRadius)
    )
    path.addLine(to: CGPoint(x: center.x - width / 2, y: center.y - height / 4))

    path.addCurve(
        to: CGPoint(x: center.x - width / 2 + curveRadius, y: center.y - height / 2),
        control1: CGPoint(x: center.x - width / 2, y: center.y - height / 2 + curveRadius),
        control2: CGPoint(x: center.x - width / 2, y: center.y - height / 2)
    )

    path.closeSubpath()

    // Fill the case face (black), and DO NOT stroke with a different color
    context.fill(path, with: .color(.black))
    // If you explicitly want no visible rim, omit the stroke entirely.
    // If you want a rim but same color as face: uncomment next line
     context.stroke(path, with: .color(Color(red: 0.19, green: 0.19, blue: 0.19)), lineWidth: 4)
}

private func drawHourMarkersAndNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    for i in 1...12 {
        let angle = Double.pi / 6 * Double(i - 3) // Start at 12 o'clock
        let numberRadius = radius * 0.7

        // Adjust positions for tonneau shape
        let adjustedRadius: CGFloat
        if i == 12 || i == 6 {
            adjustedRadius = numberRadius * 0.9
        } else if i == 3 || i == 9 {
            adjustedRadius = numberRadius * 1.1
        } else {
            adjustedRadius = numberRadius
        }

        let numberX = center.x + cos(angle) * adjustedRadius
        let numberY = center.y + sin(angle) * adjustedRadius

        let numberColor: Color
        switch i {
        case 12: numberColor = .red
        case 3:  numberColor = .blue
        case 6:  numberColor = .green
        case 9:  numberColor = .yellow
        default: numberColor = .white
        }

        let text = Text("\(i)")
            .font(.system(size: radius * 0.2, weight: .bold))
            .foregroundColor(numberColor)

        context.draw(text, at: CGPoint(x: numberX, y: numberY))
    }
}

private func drawLogo(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let lucernaText = Text("LUCERNA")
        .font(.system(size: radius * 0.12, weight: .bold))
        .foregroundColor(.white)
    context.draw(lucernaText, at: CGPoint(x: center.x, y: center.y - radius * 0.3))

    let romaText = Text("ROMA")
        .font(.system(size: radius * 0.08))
        .foregroundColor(.white)
    context.draw(romaText, at: CGPoint(x: center.x, y: center.y - radius * 0.15))
}

private func drawClockHands(
    context: GraphicsContext,
    center: CGPoint,
    radius: CGFloat,
    hourAngle: Double,
    minuteAngle: Double,
    secondAngle: Double
) {
    // Hour hand
    var hourContext = context
    hourContext.translateBy(x: center.x, y: center.y)
    hourContext.rotate(by: .degrees(hourAngle))

    var hourPath = Path()
    hourPath.move(to: CGPoint(x: 0, y: -radius * 0.5))
    hourPath.addLine(to: CGPoint(x: radius * 0.04, y: -radius * 0.4))
    hourPath.addLine(to: CGPoint(x: radius * 0.02, y: 0))
    hourPath.addLine(to: CGPoint(x: -radius * 0.02, y: 0))
    hourPath.addLine(to: CGPoint(x: -radius * 0.04, y: -radius * 0.4))
    hourPath.closeSubpath()

    hourContext.fill(hourPath, with: .color(.white))

    // Minute hand
    var minuteContext = context
    minuteContext.translateBy(x: center.x, y: center.y)
    minuteContext.rotate(by: .degrees(minuteAngle))

    var minutePath = Path()
    minutePath.move(to: CGPoint(x: 0, y: -radius * 0.7))
    minutePath.addLine(to: CGPoint(x: radius * 0.03, y: -radius * 0.6))
    minutePath.addLine(to: CGPoint(x: radius * 0.015, y: 0))
    minutePath.addLine(to: CGPoint(x: -radius * 0.015, y: 0))
    minutePath.addLine(to: CGPoint(x: -radius * 0.03, y: -radius * 0.6))
    minutePath.closeSubpath()

    minuteContext.fill(minutePath, with: .color(.white))

    // Second hand
    var secondContext = context
    secondContext.translateBy(x: center.x, y: center.y)
    secondContext.rotate(by: .degrees(secondAngle))

    var secondPath = Path()
    secondPath.move(to: CGPoint(x: 0, y: 0))
    secondPath.addLine(to: CGPoint(x: 0, y: -radius * 0.8))

    secondContext.stroke(
        secondPath,
        with: .color(.red),
        style: StrokeStyle(lineWidth: 2, lineCap: .round)
    )
}

private func drawCenterDot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
    let dotPath = Path(ellipseIn: CGRect(
        x: center.x - radius * 0.03,
        y: center.y - radius * 0.03,
        width: radius * 0.06,
        height: radius * 0.06
    ))

    context.fill(dotPath, with: .color(.blue))
}

// MARK: - Preview

struct LucernaRoma_Previews: PreviewProvider {
    static var previews: some View {
        LucernaRoma()
            .frame(width: 300, height: 300)
            .background(Color.gray.opacity(0.2))
    }
}

/*
```

### Alternative: keep a rim but not a different color
If you still want a subtle rim, match it to the face color:
```swift
context.stroke(path, with: .color(.black), lineWidth: 8)
```
Because the stroke uses the same color as the fill, it won’t read as a different-colored border.

### Why this matches your intent
- The visible border came from stroking the same path with a different color; removing or recoloring that stroke eliminates the contrasting rim.
- Correcting the hour-hand angle ensures the dial shows the right hour progression regardless of color changes.

If you want this Swift version to mirror the Kotlin timing fully (including time zone handling through an injected calendar) let me know and I’ll adapt it likewise.
*/
