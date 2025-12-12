import Foundation

// Time zone information structure
struct TimeZoneInfo: Identifiable, Hashable {
    let id: String
    let displayName: String
    
    init(timeZone: TimeZone) {
        self.id = timeZone.identifier
        self.displayName = timeZone.localizedName(for: .standard, locale: .current) ?? timeZone.identifier
    }
}

// Service for time zone management (equivalent to Android TimeZoneService)
class TimeZoneService: ObservableObject {
    
    // Cache for time zones to avoid repeated calculations
    private var cachedTimeZones: [TimeZoneInfo]?
    
    // Get all available time zones with display names
    func getAllTimeZones() -> [TimeZoneInfo] {
        if let cached = cachedTimeZones {
            return cached
        }
        
        let timeZones = TimeZone.knownTimeZoneIdentifiers
            .compactMap { TimeZone(identifier: $0) }
            .map { TimeZoneInfo(timeZone: $0) }
            .sorted { $0.displayName < $1.displayName }
        
        // Remove duplicates based on display name
        let uniqueTimeZones = timeZones.reduce(into: [TimeZoneInfo]()) { result, timeZone in
            if !result.contains(where: { $0.displayName == timeZone.displayName }) {
                result.append(timeZone)
            }
        }
        
        cachedTimeZones = uniqueTimeZones
        return uniqueTimeZones
    }
    
    // Get display name for a specific time zone
    func getTimeZoneDisplayName(for identifier: String) -> String {
        guard let timeZone = TimeZone(identifier: identifier) else {
            return identifier
        }
        return timeZone.localizedName(for: .standard, locale: .current) ?? identifier
    }
    
    // Get current system time zone
    func getCurrentTimeZone() -> TimeZone {
        return TimeZone.current
    }
    
    // Get current system time zone identifier
    func getCurrentTimeZoneId() -> String {
        return TimeZone.current.identifier
    }
    
    // Get TimeZone object from identifier
    func getTimeZone(from identifier: String) -> TimeZone {
        return TimeZone(identifier: identifier) ?? TimeZone.current
    }
    
    // Popular time zones for quick selection
    func getPopularTimeZones() -> [TimeZoneInfo] {
        let popularIdentifiers = [
            "America/New_York",
            "America/Chicago", 
            "America/Denver",
            "America/Los_Angeles",
            "Europe/London",
            "Europe/Paris",
            "Europe/Berlin",
            "Europe/Rome",
            "Asia/Tokyo",
            "Asia/Shanghai",
            "Asia/Kolkata",
            "Australia/Sydney"
        ]
        
        return popularIdentifiers
            .compactMap { TimeZone(identifier: $0) }
            .map { TimeZoneInfo(timeZone: $0) }
    }
}