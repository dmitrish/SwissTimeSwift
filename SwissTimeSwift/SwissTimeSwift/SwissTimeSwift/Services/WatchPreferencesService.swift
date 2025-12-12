import Foundation

// Service for managing watch-related preferences (equivalent to Android WatchPreferencesRepository)
class WatchPreferencesService: ObservableObject {
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private struct Keys {
        static let selectedWatches = "selected_watches"
        static let selectedTimeZone = "selected_timezone"
        static let useUSTimeFormat = "use_us_time_format"
        static let useDoubleTapForRemoval = "use_double_tap_for_removal"
        static let watchTimeZonePrefix = "watch_timezone_"
    }
    
    // MARK: - Selected Watches
    
    func getSelectedWatchNames() -> Set<String> {
        if let array = userDefaults.array(forKey: Keys.selectedWatches) as? [String] {
            return Set(array)
        }
        return []
    }
    
    func saveSelectedWatchNames(_ watchNames: Set<String>) {
        userDefaults.set(Array(watchNames), forKey: Keys.selectedWatches)
    }
    
    func addSelectedWatch(_ watchName: String) {
        var current = getSelectedWatchNames()
        current.insert(watchName)
        saveSelectedWatchNames(current)
    }
    
    func removeSelectedWatch(_ watchName: String) {
        var current = getSelectedWatchNames()
        current.remove(watchName)
        saveSelectedWatchNames(current)
    }
    
    func clearAllSelectedWatches() {
        userDefaults.removeObject(forKey: Keys.selectedWatches)
    }
    
    // MARK: - Time Zone Management
    
    func getSelectedTimeZone() -> String? {
        return userDefaults.string(forKey: Keys.selectedTimeZone)
    }
    
    func saveSelectedTimeZone(_ timeZoneId: String) {
        userDefaults.set(timeZoneId, forKey: Keys.selectedTimeZone)
    }
    
    func clearSelectedTimeZone() {
        userDefaults.removeObject(forKey: Keys.selectedTimeZone)
    }
    
    // MARK: - Watch-specific Time Zones
    
    func getWatchTimeZone(watchName: String) -> String? {
        let key = Keys.watchTimeZonePrefix + watchName
        return userDefaults.string(forKey: key)
    }
    
    func saveWatchTimeZone(watchName: String, timeZoneId: String) {
        let key = Keys.watchTimeZonePrefix + watchName
        userDefaults.set(timeZoneId, forKey: key)
    }
    
    func clearWatchTimeZone(watchName: String) {
        let key = Keys.watchTimeZonePrefix + watchName
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - App Settings
    
    func getUseUSTimeFormat() -> Bool {
        return userDefaults.object(forKey: Keys.useUSTimeFormat) as? Bool ?? true
    }
    
    func saveUseUSTimeFormat(_ useUSFormat: Bool) {
        userDefaults.set(useUSFormat, forKey: Keys.useUSTimeFormat)
    }
    
    func getUseDoubleTapForRemoval() -> Bool {
        return userDefaults.object(forKey: Keys.useDoubleTapForRemoval) as? Bool ?? false
    }
    
    func saveUseDoubleTapForRemoval(_ useDoubleTap: Bool) {
        userDefaults.set(useDoubleTap, forKey: Keys.useDoubleTapForRemoval)
    }
}