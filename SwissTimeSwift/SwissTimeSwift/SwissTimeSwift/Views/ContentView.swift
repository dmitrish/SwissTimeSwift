import SwiftUI

 // Main container view with tab navigation - FIXED VERSION
 struct ContentView: View {
     @EnvironmentObject var watchViewModel: WatchViewModel
     @EnvironmentObject var themeViewModel: ThemeViewModel
     @EnvironmentObject var timeZoneViewModel: TimeZoneViewModel

     @State private var selectedTab = 0

     var body: some View {
         TabView(selection: $selectedTab) {
             // Time View
             NavigationView {
                 if watchViewModel.selectedWatches.isEmpty && watchViewModel.selectedWatchesLoaded {
                     WelcomeView()
                 } else {
                     TimeView()
                 }
             }
             .navigationViewStyle(StackNavigationViewStyle()) // Force single column on iPad
             .tabItem {
                 Image(systemName: "clock")
                 Text("Time")
             }
             .tag(0)

             // Watch List
             NavigationView {
                 WatchListView()
             }
             .navigationViewStyle(StackNavigationViewStyle())
             .tabItem {
                 Image(systemName: "watchface.applewatch.case")
                 Text("Watches")
             }
             .tag(1)

             // Settings
             NavigationView {
                 SettingsView()
             }
             .navigationViewStyle(StackNavigationViewStyle())
             .tabItem {
                 Image(systemName: "gear")
                 Text("Settings")
             }
             .tag(2)

             // About
             NavigationView {
                 AboutView()
             }
             .navigationViewStyle(StackNavigationViewStyle())
             .tabItem {
                 Image(systemName: "info.circle")
                 Text("About")
             }
             .tag(3)
         }
         .preferredColorScheme(themeViewModel.colorScheme)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .background(Color("SwissTimePrimary"))
         .ignoresSafeArea() // Important! Extends to edges
     }
 }

 // MARK: - Preview
 #Preview {
     ContentView()
         .environmentObject(WatchViewModel())
         .environmentObject(ThemeViewModel())
         .environmentObject(TimeZoneViewModel())
 }


