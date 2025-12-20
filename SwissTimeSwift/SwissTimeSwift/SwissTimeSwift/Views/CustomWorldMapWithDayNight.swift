//
//  CustomWorldMapWithDayNight.swift
//  SwissTimeSwift
//
//  Created by Shpinar Dmitri on 12/15/25.
//


import SwiftUI
import CoreGraphics

struct CustomWorldMapWithDayNight: View {
    @State private var currentTime = Date()
    
    let nightOverlayColor: Color
    let updateIntervalMillis: TimeInterval
    let pixelDensity: CGFloat
    
    // Constants from earth.py
    let blur: CGFloat = 4.0
    let phong: Bool = true
    let shadDiv: CGFloat = 260.0
    let diffInt: CGFloat = 1.0
    let specExp: CGFloat = 4.0
    
    init(
        // Color(red: 0.07, green: 0.13, blue: 0.20),
        nightOverlayColor: Color = .appPrimary,
        updateIntervalMillis: TimeInterval = 6.0,
        pixelDensity: CGFloat? = nil
    ) {
        self.nightOverlayColor = nightOverlayColor
        self.updateIntervalMillis = updateIntervalMillis
        
        // Auto-detect device performance tier
        if let density = pixelDensity {
            self.pixelDensity = density
        } else {
            // Determine pixel density based on device capabilities
            let processorCount = ProcessInfo.processInfo.processorCount
            if processorCount >= 8 {
                self.pixelDensity = 180.0 // High-end devices
            } else {
                self.pixelDensity = 180.0 // Standard devices
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // World map image
                if let worldImage = UIImage(named: "world") {
                    Image(uiImage: worldImage)
                        .resizable()
                        .aspectRatio(2.0, contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.width / 2)
                    
                    // Night overlay canvas
                    Canvas { context, size in
                        drawNightOverlay(
                            context: context,
                            size: size,
                            currentTime: currentTime
                        )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width / 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        }
        .aspectRatio(2.0, contentMode: .fit)
        .onAppear {
            startTimer()
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
        
        // Calculate sun position
        let sunPosition = calculateSunPosition(date: currentTime)
        
        // Calculate step size based on pixel density
        let stepSize = max(1, Int(width / pixelDensity))
        
        // Draw night overlay
        for y in stride(from: 0, to: Int(height), by: stepSize) {
            for x in stride(from: 0, to: Int(width), by: stepSize) {
                let xOffset = width * 0.16
                let adjustedX = CGFloat(x) + xOffset
                let longitude = (adjustedX / width * 360.0) - 180.0
                let latitude = 90.0 - (CGFloat(y) / height * 180.0)
                
                let altitude = calculateSunAltitude(
                    latitude: latitude,
                    longitude: longitude,
                    sunPosition: sunPosition
                )
                
                let nightAlpha: CGFloat
                if altitude < -blur {
                    nightAlpha = 0.42 // Deeper night
                } else if altitude > blur {
                    nightAlpha = 0.0 // Full day
                } else {
                    // Smooth terminator blend
                    let t = (altitude + blur) / (blur * 2.0)
                    nightAlpha = 0.42 * (1.0 - t)
                }
                
                if nightAlpha > 0.01 {
                    let rect = CGRect(
                        x: CGFloat(x),
                        y: CGFloat(y),
                        width: CGFloat(stepSize),
                        height: CGFloat(stepSize)
                    )
                    context.fill(
                        Path(rect),
                        with: .color(nightOverlayColor.opacity(nightAlpha))
                    )
                }
            }
        }
    }
    
    private func calculateSunPosition(date: Date) -> SunPosition {
        // Use Eastern Time Zone (America/New_York)
        let calendar = Calendar.current
        var easternTimeZone = TimeZone(identifier: "America/New_York")!
        
        let components = calendar.dateComponents(
            in: easternTimeZone,
            from: date
        )
        
        let year = components.year!
        let month = components.month!
        let day = components.day!
        let hour = components.hour!
        let minute = components.minute!
        let second = components.second!
        
        let hourDecimal = CGFloat(hour) + CGFloat(minute) / 60.0 + CGFloat(second) / 3600.0
        
        // Calculate days since J2000 (January 1, 2000 12:00 UTC)
        let daysToJ2000 = CGFloat(
            367 * year - 7 * (year + (month + 9) / 12) / 4 + 275 * month / 9 + day - 730530
        ) + hourDecimal / 24.0
        
        // Orbital elements of the Earth
        let w = 282.9404 + 4.70935e-5 * daysToJ2000 // longitude of perihelion
        let e = 0.016709 - 1.151e-9 * daysToJ2000 // eccentricity
        let M = rev(356.0470 + 0.9856002585 * daysToJ2000) // mean anomaly
        let oblecl = 23.4393 - 3.563e-7 * daysToJ2000 // obliquity of the ecliptic
        
        // Sun's longitude
        let L = rev(w + M)
        
        // Eccentric anomaly
        let E = M + (180.0 / CGFloat.pi) * e * sin(M * CGFloat.pi / 180.0) *
            (1.0 + e * cos(M * CGFloat.pi / 180.0))
        
        // Sun's rectangular coordinates in the plane of the ecliptic
        let x = cos(E * CGFloat.pi / 180.0) - e
        let y = sin(E * CGFloat.pi / 180.0) * sqrt(1.0 - e * e)
        
        // Distance and true anomaly
        let r = sqrt(x * x + y * y)
        let v = atan2(y, x) * (180.0 / CGFloat.pi)
        
        // Sun's longitude
        let sunLongitude = rev(v + w)
        
        // Sun's ecliptic rectangular coordinates
        let xeclip = r * cos(sunLongitude * CGFloat.pi / 180.0)
        let yeclip = r * sin(sunLongitude * CGFloat.pi / 180.0)
        
        // Rotate to equatorial coordinates
        let xequat = xeclip
        let yequat = yeclip * cos(oblecl * CGFloat.pi / 180.0)
        let zequat = yeclip * sin(oblecl * CGFloat.pi / 180.0)
        
        // Calculate Right Ascension and Declination
        let RA = atan2(yequat, xequat) * (180.0 / CGFloat.pi) / 15.0
        let Decl = asin(zequat / r) * (180.0 / CGFloat.pi)
        
        // Calculate Greenwich Mean Sidereal Time
        let GMST0 = (L * CGFloat.pi / 180.0 + CGFloat.pi) / 15.0 * (180.0 / CGFloat.pi)
        
        return SunPosition(
            RA: RA,
            Decl: Decl,
            GMST0: GMST0,
            hourDecimal: hourDecimal
        )
    }
    
    private func calculateSunAltitude(
        latitude: CGFloat,
        longitude: CGFloat,
        sunPosition: SunPosition
    ) -> CGFloat {
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
        
        let altitude = atan2(zhor, sqrt(xhor * xhor + yhor * yhor)) * (180.0 / CGFloat.pi)
        
        return altitude
    }
    
    // Helper function to normalize an angle to the range [0, 360)
    private func rev(_ x: CGFloat) -> CGFloat {
        var rv = x - CGFloat(Int(x / 360.0)) * 360.0
        if rv < 0 {
            rv += 360.0
        }
        return rv
    }
}

struct SunPosition {
    let RA: CGFloat // Right Ascension
    let Decl: CGFloat // Declination
    let GMST0: CGFloat // Greenwich Mean Sidereal Time
    let hourDecimal: CGFloat
}

// Preview provider
struct CustomWorldMapWithDayNight_Previews: PreviewProvider {
    static var previews: some View {
        CustomWorldMapWithDayNight()
            .frame(width: 400, height: 200)
    }
}
