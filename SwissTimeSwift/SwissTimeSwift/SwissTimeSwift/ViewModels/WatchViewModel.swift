import SwiftUI
import Foundation

// Main view model for watch management (equivalent to Android WatchViewModel)
class WatchViewModel: ObservableObject {
    @Published var selectedWatches: [WatchInfo] = []
    @Published var selectedWatchesLoaded: Bool = false
    @Published var availableWatches: [WatchInfo] = WatchInfo.allWatches
    
    private let watchPreferencesService: WatchPreferencesService
    private let timeZoneService: TimeZoneService
    
    init(watchPreferencesService: WatchPreferencesService = WatchPreferencesService(),
         timeZoneService: TimeZoneService = TimeZoneService()) {
        self.watchPreferencesService = watchPreferencesService
        self.timeZoneService = timeZoneService
        loadSelectedWatches()
    }
    
    // Load selected watches from persistent storage
    private func loadSelectedWatches() {
        let selectedNames = AppSettings.selectedWatchNames
        selectedWatches = availableWatches.filter { watch in
            selectedNames.contains(watch.name)
        }
        selectedWatchesLoaded = true
    }
    
    // Toggle watch selection (add/remove from favorites)
    func toggleWatchSelection(_ watch: WatchInfo) -> Bool {
        if let index = selectedWatches.firstIndex(of: watch) {
            // Remove watch
            selectedWatches.remove(at: index)
            saveSelectedWatches()
            return false
        } else {
            // Add watch
            selectedWatches.append(watch)
            saveSelectedWatches()
            return true
        }
    }
    
    // Check if a watch is currently selected
    func isWatchSelected(_ watch: WatchInfo) -> Bool {
        return selectedWatches.contains(watch)
    }
    
    // Save selected watches to persistent storage
    private func saveSelectedWatches() {
        let watchNames = Set(selectedWatches.map { $0.name })
        AppSettings.selectedWatchNames = watchNames
    }
    
    // Add a watch to selection
    func addWatch(_ watch: WatchInfo) {
        if !selectedWatches.contains(watch) {
            selectedWatches.append(watch)
            saveSelectedWatches()
        }
    }
    
    // Remove a watch from selection
    func removeWatch(_ watch: WatchInfo) {
        if let index = selectedWatches.firstIndex(of: watch) {
            selectedWatches.remove(at: index)
            saveSelectedWatches()
        }
    }
    
    // Clear all selected watches
    func clearAllSelectedWatches() {
        selectedWatches.removeAll()
        saveSelectedWatches()
    }
    
    // Get time zone for specific watch
    func getTimeZone(for watchName: String) -> TimeZone {
        if let timeZoneId = watchPreferencesService.getWatchTimeZone(watchName: watchName) {
            return TimeZone(identifier: timeZoneId) ?? TimeZone.current
        }
        return TimeZone.current
    }
    
    // Save time zone for specific watch
    func saveTimeZone(_ timeZone: TimeZone, for watchName: String) {
        watchPreferencesService.saveWatchTimeZone(watchName: watchName, timeZoneId: timeZone.identifier)
    }
}