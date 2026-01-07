import SwiftUI
import Foundation

// Main view model for watch management (equivalent to Android WatchViewModel)
class WatchViewModel: ObservableObject {
    @Published var selectedWatches: [WatchInfo] = []
    @Published var selectedWatchesLoaded: Bool = false
    @Published var availableWatches: [WatchInfo] = WatchInfo.allWatches
    
    // Track per-watch time zones with Published for UI updates
    @Published private var watchTimeZones: [String: TimeZone] = [:]
    
    private let watchPreferencesService: WatchPreferencesService
    private let timeZoneService: TimeZoneService
    
    init(watchPreferencesService: WatchPreferencesService = WatchPreferencesService(),
         timeZoneService: TimeZoneService = TimeZoneService()) {
        self.watchPreferencesService = watchPreferencesService
        self.timeZoneService = timeZoneService
        loadSelectedWatches()
        loadWatchTimeZones()
    }
    
    // Load selected watches from persistent storage
    private func loadSelectedWatches() {
        let selectedNames = AppSettings.selectedWatchNames
        selectedWatches = availableWatches.filter { watch in
            selectedNames.contains(watch.name)
        }
        selectedWatchesLoaded = true
    }
    
    // Load persisted time zones for all watches
    private func loadWatchTimeZones() {
        for watch in availableWatches {
            if let timeZoneId = watchPreferencesService.getWatchTimeZone(watchName: watch.name),
               let timeZone = TimeZone(identifier: timeZoneId) {
                watchTimeZones[watch.name] = timeZone
            }
        }
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
        // First check in-memory cache
        if let timeZone = watchTimeZones[watchName] {
            return timeZone
        }
        // Then check persistent storage
        if let timeZoneId = watchPreferencesService.getWatchTimeZone(watchName: watchName),
           let timeZone = TimeZone(identifier: timeZoneId) {
            watchTimeZones[watchName] = timeZone
            return timeZone
        }
        return TimeZone.current
    }
    
    // Save time zone for specific watch
    func saveTimeZone(_ timeZone: TimeZone, for watchName: String) {
        // Update in-memory cache (triggers @Published update)
        watchTimeZones[watchName] = timeZone
        // Persist to UserDefaults
        watchPreferencesService.saveWatchTimeZone(watchName: watchName, timeZoneId: timeZone.identifier)
        // Force objectWillChange to ensure UI updates
        objectWillChange.send()
    }
}