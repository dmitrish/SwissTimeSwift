import Foundation

// Settings model matching Android app preferences
struct AppSettings: Codable {
    var selectedWatchNames: Set<String> = []
    var selectedTimeZoneId: String = TimeZone.current.identifier
    var useUSTimeFormat: Bool = true
    var useDoubleTapForRemoval: Bool = false
    var themeMode: ThemeMode = .system
    
    // Theme preference
    enum ThemeMode: String, CaseIterable, Codable {
        case light = "Light"
        case dark = "Dark" 
        case system = "System"
        
        var displayName: String {
            return self.rawValue
        }
    }
}

// Extension for UserDefaults storage
extension AppSettings {
    static let shared = AppSettings()
    
    private static let userDefaults = UserDefaults.standard
    private static let settingsKey = "AppSettings"
    
    static func load() -> AppSettings {
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        AppSettings.userDefaults.set(data, forKey: AppSettings.settingsKey)
    }
    
    // Individual preference accessors for backwards compatibility
    static var selectedWatchNames: Set<String> {
        get { load().selectedWatchNames }
        set {
            var settings = load()
            settings.selectedWatchNames = newValue
            settings.save()
        }
    }
    
    static var selectedTimeZoneId: String {
        get { load().selectedTimeZoneId }
        set {
            var settings = load()
            settings.selectedTimeZoneId = newValue
            settings.save()
        }
    }
    
    static var useUSTimeFormat: Bool {
        get { load().useUSTimeFormat }
        set {
            var settings = load()
            settings.useUSTimeFormat = newValue
            settings.save()
        }
    }
    
    static var useDoubleTapForRemoval: Bool {
        get { load().useDoubleTapForRemoval }
        set {
            var settings = load()
            settings.useDoubleTapForRemoval = newValue
            settings.save()
        }
    }
    
    static var themeMode: ThemeMode {
        get { load().themeMode }
        set {
            var settings = load()
            settings.themeMode = newValue
            settings.save()
        }
    }
}