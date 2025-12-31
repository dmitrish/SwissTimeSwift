//
//  CustomWorldMapWithDayNight.swift
//  SwissTimeSwift
//

import SwiftUI
import CoreGraphics

struct CustomWorldMapWithDayNight: View {
    @State private var currentTime = Date()
    @State private var waterViewModel = WaterViewModel()
    @State private var waterTimeSeconds: Float = 0
    @State private var waterStartTime: CFTimeInterval = 0
    @State private var currentPointerId: Int = 0
    @State private var useShader: Bool = true  // ON by default
    
    let nightOverlayColor: Color
    let updateIntervalMillis: TimeInterval
    let pixelDensity: CGFloat
    
    let blur: CGFloat = 4.0
    let phong: Bool = true
    let shadDiv: CGFloat = 260.0
    let diffInt: CGFloat = 1.0
    let specExp: CGFloat = 4.0
    
    init(
        nightOverlayColor: Color = .appPrimary,
        updateIntervalMillis: TimeInterval = 6.0,
        pixelDensity: CGFloat? = nil
    ) {
        self.nightOverlayColor = nightOverlayColor
        self.updateIntervalMillis = updateIntervalMillis
        
        if let density = pixelDensity {
            self.pixelDensity = density
        } else {
            let processorCount = ProcessInfo.processInfo.processorCount
            self.pixelDensity = processorCount >= 8 ? 180.0 : 180.0
        }
    }
    
    private var waterShaderParams: WaveShaderParams {
        waterViewModel.getShaderUniforms(currentTimeSeconds: waterTimeSeconds)
    }
    
    var body: some View {
        GeometryReader { geometry in
            mapContent(geometry: geometry)
        }
        .aspectRatio(2.0, contentMode: .fit)
        .onAppear {
            startTimer()
            print("View appeared - Water shader: \(useShader ? "ENABLED" : "DISABLED")")
        }
    }
    
    @ViewBuilder
    private func mapContent(geometry: GeometryProxy) -> some View {
        if useShader {
            if #available(iOS 17.0, *) {
                mapWithShader(geometry: geometry)
            } else {
                let _ = print("⚠️ iOS 17+ required for water shader - falling back")
                mapWithoutShader(geometry: geometry)
            }
        } else {
            mapWithoutShader(geometry: geometry)
        }
    }
    
    @available(iOS 17.0, *)
    @ViewBuilder
    private func mapWithShader(geometry: GeometryProxy) -> some View {
        mapLayers(geometry: geometry)
            .modifier(
                ShaderEffectModifier(
                    waterTimeSeconds: waterTimeSeconds,
                    geometry: geometry,
                    shaderParams: waterShaderParams,
                    onError: { error in
                        // On error, disable shader and fall back
                        print("❌ Shader error: \(error) - falling back to no shader")
                        useShader = false
                    }
                )
            )
            .gesture(dragGesture)
            .task {
                // Background task to update time
                while !Task.isCancelled {
                    let currentDate = Date()
                    if waterStartTime == 0 {
                        waterStartTime = currentDate.timeIntervalSince1970
                    }
                    waterTimeSeconds = Float(currentDate.timeIntervalSince1970 - waterStartTime)
                    waterViewModel.cleanupWaves(currentTimeSeconds: waterTimeSeconds)
                    
                    try? await Task.sleep(for: .milliseconds(16)) // ~60fps
                }
            }
    }
    
    @ViewBuilder
    private func mapWithoutShader(geometry: GeometryProxy) -> some View {
        mapLayers(geometry: geometry)
            .gesture(dragGesture)
    }
    
    @ViewBuilder
    private func mapLayers(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .center) {
            Image("world")
                .resizable()
                .aspectRatio(2.0, contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.width / 2)
            
            Canvas { context, size in
                drawNightOverlay(context: context, size: size, currentTime: currentTime)
            }
            .frame(width: geometry.size.width, height: geometry.size.width / 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                waterViewModel.addWave(
                    position: value.location,
                    pointerId: currentPointerId,
                    currentTimeSeconds: waterTimeSeconds
                )
            }
            .onEnded { _ in
                currentPointerId += 1
            }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: updateIntervalMillis, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func drawNightOverlay(context: GraphicsContext, size: CGSize, currentTime: Date) {
        let width = size.width
        let height = size.height
        let sunPosition = calculateSunPosition(date: currentTime)
        let stepSize = max(1, Int(width / pixelDensity))
        
        for y in stride(from: 0, to: Int(height), by: stepSize) {
            for x in stride(from: 0, to: Int(width), by: stepSize) {
                let xOffset = width * 0.16
                let adjustedX = CGFloat(x) + xOffset
                let longitude = (adjustedX / width * 360.0) - 180.0
                let latitude = 90.0 - (CGFloat(y) / height * 180.0)
                
                let altitude = calculateSunAltitude(latitude: latitude, longitude: longitude, sunPosition: sunPosition)
                
                let nightAlpha: CGFloat
                if altitude < -blur {
                    nightAlpha = 0.42
                } else if altitude > blur {
                    nightAlpha = 0.0
                } else {
                    let t = (altitude + blur) / (blur * 2.0)
                    nightAlpha = 0.42 * (1.0 - t)
                }
                
                if nightAlpha > 0.01 {
                    context.fill(Path(CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(stepSize), height: CGFloat(stepSize))), with: .color(nightOverlayColor.opacity(nightAlpha)))
                }
            }
        }
    }
    
    private func calculateSunPosition(date: Date) -> SunPosition {
        let calendar = Calendar.current
        let easternTimeZone = TimeZone(identifier: "America/New_York")!
        let components = calendar.dateComponents(in: easternTimeZone, from: date)
        
        let year = components.year!, month = components.month!, day = components.day!
        let hour = components.hour!, minute = components.minute!, second = components.second!
        
        let hourDecimal = CGFloat(hour) + CGFloat(minute) / 60.0 + CGFloat(second) / 3600.0
        let daysToJ2000 = CGFloat(367 * year - 7 * (year + (month + 9) / 12) / 4 + 275 * month / 9 + day - 730530) + hourDecimal / 24.0
        
        let w = 282.9404 + 4.70935e-5 * daysToJ2000
        let e = 0.016709 - 1.151e-9 * daysToJ2000
        let M = rev(356.0470 + 0.9856002585 * daysToJ2000)
        let oblecl = 23.4393 - 3.563e-7 * daysToJ2000
        let L = rev(w + M)
        let E = M + (180.0 / CGFloat.pi) * e * sin(M * CGFloat.pi / 180.0) * (1.0 + e * cos(M * CGFloat.pi / 180.0))
        
        let x = cos(E * CGFloat.pi / 180.0) - e
        let y = sin(E * CGFloat.pi / 180.0) * sqrt(1.0 - e * e)
        let r = sqrt(x * x + y * y)
        let v = atan2(y, x) * (180.0 / CGFloat.pi)
        let sunLongitude = rev(v + w)
        
        let xeclip = r * cos(sunLongitude * CGFloat.pi / 180.0)
        let yeclip = r * sin(sunLongitude * CGFloat.pi / 180.0)
        let xequat = xeclip
        let yequat = yeclip * cos(oblecl * CGFloat.pi / 180.0)
        let zequat = yeclip * sin(oblecl * CGFloat.pi / 180.0)
        
        let RA = atan2(yequat, xequat) * (180.0 / CGFloat.pi) / 15.0
        let Decl = asin(zequat / r) * (180.0 / CGFloat.pi)
        let GMST0 = (L * CGFloat.pi / 180.0 + CGFloat.pi) / 15.0 * (180.0 / CGFloat.pi)
        
        return SunPosition(RA: RA, Decl: Decl, GMST0: GMST0, hourDecimal: hourDecimal)
    }
    
    private func calculateSunAltitude(latitude: CGFloat, longitude: CGFloat, sunPosition: SunPosition) -> CGFloat {
        let latRad = latitude * CGFloat.pi / 180.0
        let SIDTIME = sunPosition.GMST0 + sunPosition.hourDecimal + longitude / 15.0
        let HA = rev(SIDTIME - sunPosition.RA) * 15.0
        let HArad = HA * CGFloat.pi / 180.0
        let declRad = sunPosition.Decl * CGFloat.pi / 180.0
        
        let xval = cos(HArad) * cos(declRad)
        let yval = sin(HArad) * cos(declRad)
        let zval = sin(declRad)
        let xhor = xval * sin(latRad) - zval * cos(latRad)
        let yhor = yval
        let zhor = xval * cos(latRad) + zval * sin(latRad)
        
        return atan2(zhor, sqrt(xhor * xhor + yhor * yhor)) * (180.0 / CGFloat.pi)
    }
    
    private func rev(_ x: CGFloat) -> CGFloat {
        var rv = x - CGFloat(Int(x / 360.0)) * 360.0
        if rv < 0 { rv += 360.0 }
        return rv
    }
}

@available(iOS 17.0, *)
struct ShaderEffectModifier: ViewModifier {
    let waterTimeSeconds: Float
    let geometry: GeometryProxy
    let shaderParams: WaveShaderParams
    let onError: (String) -> Void
    
    func body(content: Content) -> some View {
        let w0 = shaderParams.wave0
        let w1 = shaderParams.wave1
        let w2 = shaderParams.wave2
        let w3 = shaderParams.wave3
        let w4 = shaderParams.wave4
        
        content
            .layerEffect(
                ShaderLibrary.waterDistortion(
                    .float(waterTimeSeconds),
                    .float2(CGSize(width: geometry.size.width, height: geometry.size.width / 2)),
                    .float(shaderParams.globalDamping),
                    .float(shaderParams.minAmplitudeThreshold),
                    .float(Float(shaderParams.numWaves)),
                    // Wave 0
                    .float2(w0.origin),
                    .float(w0.amplitude),
                    .float(w0.frequency),
                    .float(w0.speed),
                    .float(w0.startTime),
                    // Wave 1
                    .float2(w1.origin),
                    .float(w1.amplitude),
                    .float(w1.frequency),
                    .float(w1.speed),
                    .float(w1.startTime),
                    // Wave 2
                    .float2(w2.origin),
                    .float(w2.amplitude),
                    .float(w2.frequency),
                    .float(w2.speed),
                    .float(w2.startTime),
                    // Wave 3
                    .float2(w3.origin),
                    .float(w3.amplitude),
                    .float(w3.frequency),
                    .float(w3.speed),
                    .float(w3.startTime),
                    // Wave 4
                    .float2(w4.origin),
                    .float(w4.amplitude),
                    .float(w4.frequency),
                    .float(w4.speed),
                    .float(w4.startTime)
                ),
                maxSampleOffset: CGSize(width: 120, height: 120)
            )
            .onAppear {
                print("✅ Shader effect applied successfully")
            }
    }
}

struct SunPosition {
    let RA: CGFloat
    let Decl: CGFloat
    let GMST0: CGFloat
    let hourDecimal: CGFloat
}
