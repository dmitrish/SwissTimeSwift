//
//  SwissTimeSwiftTests.swift
//  SwissTimeSwiftTests
//
//  Created by Shpinar Dmitri on 12/11/25.
//

import Testing
import Foundation
@testable import SwissTimeSwift

// MARK: - WatchViewModel Tests

struct WatchViewModelTests {
    
    @Test func testInitialStateHasAllAvailableWatches() async throws {
        let viewModel = WatchViewModel()
        
        #expect(viewModel.availableWatches.count == WatchInfo.allWatches.count)
        #expect(viewModel.availableWatches.count == 19)
    }
    
    @Test func testToggleWatchSelectionAddsWatch() async throws {
        let viewModel = WatchViewModel()
        let watch = WatchInfo.allWatches[0]
        
        // Ensure watch is not selected initially
        viewModel.clearAllSelectedWatches()
        #expect(!viewModel.isWatchSelected(watch))
        
        // Toggle selection - should add
        let wasAdded = viewModel.toggleWatchSelection(watch)
        
        #expect(wasAdded == true)
        #expect(viewModel.isWatchSelected(watch))
        #expect(viewModel.selectedWatches.contains(watch))
    }
    
    @Test func testToggleWatchSelectionRemovesWatch() async throws {
        let viewModel = WatchViewModel()
        let watch = WatchInfo.allWatches[0]
        
        // First add the watch
        viewModel.clearAllSelectedWatches()
        viewModel.addWatch(watch)
        #expect(viewModel.isWatchSelected(watch))
        
        // Toggle selection - should remove
        let wasAdded = viewModel.toggleWatchSelection(watch)
        
        #expect(wasAdded == false)
        #expect(!viewModel.isWatchSelected(watch))
    }
    
    @Test func testAddWatchDoesNotDuplicate() async throws {
        let viewModel = WatchViewModel()
        let watch = WatchInfo.allWatches[0]
        
        viewModel.clearAllSelectedWatches()
        viewModel.addWatch(watch)
        viewModel.addWatch(watch)
        viewModel.addWatch(watch)
        
        // Should only appear once
        let count = viewModel.selectedWatches.filter { $0 == watch }.count
        #expect(count == 1)
    }
    
    @Test func testRemoveWatch() async throws {
        let viewModel = WatchViewModel()
        let watch = WatchInfo.allWatches[0]
        
        viewModel.clearAllSelectedWatches()
        viewModel.addWatch(watch)
        #expect(viewModel.selectedWatches.count == 1)
        
        viewModel.removeWatch(watch)
        #expect(viewModel.selectedWatches.count == 0)
        #expect(!viewModel.isWatchSelected(watch))
    }
    
    @Test func testClearAllSelectedWatches() async throws {
        let viewModel = WatchViewModel()
        
        // Add multiple watches
        viewModel.addWatch(WatchInfo.allWatches[0])
        viewModel.addWatch(WatchInfo.allWatches[1])
        viewModel.addWatch(WatchInfo.allWatches[2])
        
        #expect(viewModel.selectedWatches.count >= 3)
        
        viewModel.clearAllSelectedWatches()
        #expect(viewModel.selectedWatches.isEmpty)
    }
    
    @Test func testGetTimeZoneReturnsCurrentByDefault() async throws {
        let viewModel = WatchViewModel()
        let watchName = "TestWatch"
        
        let timeZone = viewModel.getTimeZone(for: watchName)
        #expect(timeZone == TimeZone.current)
    }
    
    @Test func testSelectedWatchesLoadedFlagIsSet() async throws {
        let viewModel = WatchViewModel()
        
        // After init, this flag should be true
        #expect(viewModel.selectedWatchesLoaded == true)
    }
}

// MARK: - WatchInfo Tests

struct WatchInfoTests {
    
    @Test func testAllWatchesHaveUniqueNames() async throws {
        let names = WatchInfo.allWatches.map { $0.name }
        let uniqueNames = Set(names)
        
        #expect(names.count == uniqueNames.count)
    }
    
    @Test func testWatchFaceTypeDisplayName() async throws {
        #expect(WatchFaceType.valentinianus.displayName == "Valentinianus Classique")
        #expect(WatchFaceType.zeitwerk.displayName == "Alpenglühen Zeitwerk")
        #expect(WatchFaceType.vostok.displayName == "Vostok Military")
    }
    
    @Test func testWatchInfoEquality() async throws {
        let watch1 = WatchInfo.allWatches[0]
        let watch2 = WatchInfo.allWatches[0]
        let watch3 = WatchInfo.allWatches[1]
        
        // Same name means equal
        #expect(watch1 == watch2)
        #expect(watch1 != watch3)
    }
    
    @Test func testWatchInfoHashable() async throws {
        var watchSet = Set<WatchInfo>()
        
        watchSet.insert(WatchInfo.allWatches[0])
        watchSet.insert(WatchInfo.allWatches[0])
        
        // Should only contain one element despite two inserts
        #expect(watchSet.count == 1)
    }
    
    @Test func testWatchFaceTypeCaseCount() async throws {
        // Verify we have all expected watch face types
        #expect(WatchFaceType.allCases.count == 19)
    }
}

// MARK: - AppSettings Tests

struct AppSettingsTests {
    
    @Test func testThemeModeAllCases() async throws {
        let allModes = AppSettings.ThemeMode.allCases
        
        #expect(allModes.count == 3)
        #expect(allModes.contains(.light))
        #expect(allModes.contains(.dark))
        #expect(allModes.contains(.system))
    }
    
    @Test func testThemeModeDisplayNames() async throws {
        #expect(AppSettings.ThemeMode.light.displayName == "Light")
        #expect(AppSettings.ThemeMode.dark.displayName == "Dark")
        #expect(AppSettings.ThemeMode.system.displayName == "System")
    }
    
    @Test func testDefaultAppSettingsValues() async throws {
        let settings = AppSettings()
        
        #expect(settings.selectedWatchNames.isEmpty)
        #expect(settings.selectedTimeZoneId == TimeZone.current.identifier)
        #expect(settings.useUSTimeFormat == true)
        #expect(settings.useDoubleTapForRemoval == false)
        #expect(settings.themeMode == .system)
    }
    
    @Test func testAppSettingsCodable() async throws {
        var original = AppSettings()
        original.selectedWatchNames = ["Watch1", "Watch2"]
        original.useUSTimeFormat = false
        original.themeMode = .dark
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        // Decode
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AppSettings.self, from: data)
        
        #expect(decoded.selectedWatchNames == original.selectedWatchNames)
        #expect(decoded.useUSTimeFormat == original.useUSTimeFormat)
        #expect(decoded.themeMode == original.themeMode)
    }
}

// MARK: - WatchPreferencesService Tests

struct WatchPreferencesServiceTests {
    
    @Test func testGetSelectedWatchNamesReturnsEmpty() async throws {
        let service = WatchPreferencesService()
        
        // Clear first
        service.clearAllSelectedWatches()
        
        let names = service.getSelectedWatchNames()
        #expect(names.isEmpty)
    }
    
    @Test func testSaveAndRetrieveSelectedWatchNames() async throws {
        let service = WatchPreferencesService()
        let testNames: Set<String> = ["Watch1", "Watch2", "Watch3"]
        
        service.saveSelectedWatchNames(testNames)
        let retrieved = service.getSelectedWatchNames()
        
        #expect(retrieved == testNames)
        
        // Cleanup
        service.clearAllSelectedWatches()
    }
    
    @Test func testAddSelectedWatch() async throws {
        let service = WatchPreferencesService()
        
        service.clearAllSelectedWatches()
        service.addSelectedWatch("NewWatch")
        
        let names = service.getSelectedWatchNames()
        #expect(names.contains("NewWatch"))
        
        // Cleanup
        service.clearAllSelectedWatches()
    }
    
    @Test func testRemoveSelectedWatch() async throws {
        let service = WatchPreferencesService()
        
        service.clearAllSelectedWatches()
        service.addSelectedWatch("WatchToRemove")
        service.addSelectedWatch("WatchToKeep")
        
        service.removeSelectedWatch("WatchToRemove")
        
        let names = service.getSelectedWatchNames()
        #expect(!names.contains("WatchToRemove"))
        #expect(names.contains("WatchToKeep"))
        
        // Cleanup
        service.clearAllSelectedWatches()
    }
    
    @Test func testSaveAndRetrieveTimeZone() async throws {
        let service = WatchPreferencesService()
        let timeZoneId = "America/New_York"
        
        service.saveSelectedTimeZone(timeZoneId)
        let retrieved = service.getSelectedTimeZone()
        
        #expect(retrieved == timeZoneId)
        
        // Cleanup
        service.clearSelectedTimeZone()
    }
    
    @Test func testWatchSpecificTimeZone() async throws {
        let service = WatchPreferencesService()
        let watchName = "TestWatch"
        let timeZoneId = "Asia/Tokyo"
        
        service.saveWatchTimeZone(watchName: watchName, timeZoneId: timeZoneId)
        let retrieved = service.getWatchTimeZone(watchName: watchName)
        
        #expect(retrieved == timeZoneId)
        
        // Cleanup
        service.clearWatchTimeZone(watchName: watchName)
    }
    
    @Test func testUseUSTimeFormat() async throws {
        let service = WatchPreferencesService()
        
        service.saveUseUSTimeFormat(false)
        #expect(service.getUseUSTimeFormat() == false)
        
        service.saveUseUSTimeFormat(true)
        #expect(service.getUseUSTimeFormat() == true)
    }
    
    @Test func testUseDoubleTapForRemoval() async throws {
        let service = WatchPreferencesService()
        
        service.saveUseDoubleTapForRemoval(true)
        #expect(service.getUseDoubleTapForRemoval() == true)
        
        service.saveUseDoubleTapForRemoval(false)
        #expect(service.getUseDoubleTapForRemoval() == false)
    }
}
