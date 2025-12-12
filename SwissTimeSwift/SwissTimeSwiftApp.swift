import SwiftUI

@main
struct SwissTimeSwiftApp: App {
    @StateObject private var watchViewModel = WatchViewModel()
    @StateObject private var themeViewModel = ThemeViewModel()
    @StateObject private var timeZoneViewModel = TimeZoneViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchViewModel)
                .environmentObject(themeViewModel)
                .environmentObject(timeZoneViewModel)
                .preferredColorScheme(themeViewModel.colorScheme)
        }
    }
}
