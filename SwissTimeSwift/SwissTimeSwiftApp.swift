import SwiftUI

@main
struct SwissTimeSwiftApp: App {
    @StateObject private var watchViewModel = WatchViewModel()
    @StateObject private var themeViewModel = ThemeViewModel()
    @StateObject private var timeZoneViewModel = TimeZoneViewModel()
    
    init() {
            // Set global background colors
            let navyColor = UIColor(named: "SwissTimePrimary")!
            
            UITabBar.appearance().backgroundColor = navyColor
            UINavigationBar.appearance().backgroundColor = navyColor
            UITableView.appearance().backgroundColor = navyColor
            UICollectionView.appearance().backgroundColor = navyColor
        }
    
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
