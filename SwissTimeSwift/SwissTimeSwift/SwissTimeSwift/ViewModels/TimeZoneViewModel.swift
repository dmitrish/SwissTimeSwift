import SwiftUI
import Foundation

// Time zone management view model
class TimeZoneViewModel: ObservableObject {
    @Published var selectedTimeZone: TimeZone {
        didSet {
            AppSettings.selectedTimeZoneId = selectedTimeZone.identifier
        }
    }
    
    @Published var availableTimeZones: [TimeZoneInfo] = []
    @Published var popularTimeZones: [TimeZoneInfo] = []
    
    private let timeZoneService: TimeZoneService
    
    init(timeZoneService: TimeZoneService = TimeZoneService()) {
        self.timeZoneService = timeZoneService
        
        // Load saved time zone or use system default
        let savedTimeZoneId = AppSettings.selectedTimeZoneId
        self.selectedTimeZone = TimeZone(identifier: savedTimeZoneId) ?? TimeZone.current
        
        loadTimeZones()
    }
    
    private func loadTimeZones() {
        availableTimeZones = timeZoneService.getAllTimeZones()
        popularTimeZones = timeZoneService.getPopularTimeZones()
    }
    
    func setTimeZone(_ timeZone: TimeZone) {
        selectedTimeZone = timeZone
    }
    
    func setTimeZone(identifier: String) {
        if let timeZone = TimeZone(identifier: identifier) {
            setTimeZone(timeZone)
        }
    }
    
    // Get current time in selected time zone
    func getCurrentTime() -> Date {
        return Date()
    }
    
    // Get formatted time string for selected time zone
    func getFormattedTime(useUSFormat: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = selectedTimeZone
        
        if useUSFormat {
            formatter.dateFormat = "h:mm:ss a"
        } else {
            formatter.dateFormat = "HH:mm:ss"
        }
        
        return formatter.string(from: Date())
    }
    
    // Get time in specific time zone
    func getTimeInTimeZone(_ timeZone: TimeZone, useUSFormat: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        
        if useUSFormat {
            formatter.dateFormat = "h:mm:ss a"
        } else {
            formatter.dateFormat = "HH:mm:ss"
        }
        
        return formatter.string(from: Date())
    }
}