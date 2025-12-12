import SwiftUI
import Foundation

// Theme management view model (equivalent to Android ThemeViewModel)
class ThemeViewModel: ObservableObject {
    @Published var themeMode: AppSettings.ThemeMode {
        didSet {
            AppSettings.themeMode = themeMode
            updateColorScheme()
        }
    }
    
    @Published var colorScheme: ColorScheme? = nil
    
    init() {
        self.themeMode = AppSettings.themeMode
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        switch themeMode {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        case .system:
            colorScheme = nil // Uses system preference
        }
    }
    
    func setTheme(_ newTheme: AppSettings.ThemeMode) {
        themeMode = newTheme
    }
    
    // Convenience computed properties
    var isDarkMode: Bool {
        switch themeMode {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            // Check system preference
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
}