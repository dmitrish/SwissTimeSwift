import SwiftUI

// Main time display view matching Android TimeScreen design
// Now with per-watch time zone support
struct TimeView: View {
    @EnvironmentObject var watchViewModel: WatchViewModel
    @EnvironmentObject var timeZoneViewModel: TimeZoneViewModel
    
    @State private var currentTime = Date()
    @State private var selectedWatchIndex = 0
    @State private var showingTimeZonePicker = false
    
    // Timer for updating time
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Get the use US time format setting
    private var useUSFormat: Bool {
        AppSettings.useUSTimeFormat
    }
    
    // Current watch being displayed
    private var currentWatch: WatchInfo? {
        guard !watchViewModel.selectedWatches.isEmpty,
              selectedWatchIndex < watchViewModel.selectedWatches.count else {
            return nil
        }
        return watchViewModel.selectedWatches[selectedWatchIndex]
    }
    
    // Time zone for the current watch
    private var currentWatchTimeZone: TimeZone {
        guard let watch = currentWatch else {
            return TimeZone.current
        }
        return watchViewModel.getTimeZone(for: watch.name)
    }
    
    // Formatted time string for current watch's time zone
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeZone = currentWatchTimeZone
        formatter.dateFormat = useUSFormat ? "h:mm:ss a" : "HH:mm:ss"
        return formatter.string(from: currentTime)
    }
    
    // Formatted date string for current watch's time zone
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = currentWatchTimeZone
        formatter.dateFormat = useUSFormat ? "MMMM d" : "d MMMM"
        return formatter.string(from: currentTime)
    }
    
    // Time zone display name for current watch
    private var timeZoneDisplayName: String {
        currentWatchTimeZone.localizedName(for: .generic, locale: .current) 
            ?? currentWatchTimeZone.identifier
    }
    
    var body: some View {
        GeometryReader { geometry in
            if watchViewModel.selectedWatches.isEmpty && watchViewModel.selectedWatchesLoaded {
                // Show empty state if no watches selected
                EmptyWatchesView()
            } else {
                VStack(spacing: 0) {
                    // Top section: Time zone, time, date
                    VStack(spacing: 4) {
                        // Time zone dropdown (sets time zone for current watch)
                        Button(action: { showingTimeZonePicker = true }) {
                            HStack(spacing: 4) {
                                Text(timeZoneDisplayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                        
                        // Current time (in current watch's time zone)
                        Text(formattedTime)
                            .font(.system(size: 28, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .monospacedDigit()
                        
                        // Current date (in current watch's time zone)
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 8)
                    
                    // Watch face pager
                    TabView(selection: $selectedWatchIndex) {
                        ForEach(Array(watchViewModel.selectedWatches.enumerated()), id: \.element.id) { index, watch in
                            WatchFaceView(
                                watch: watch,
                                timeZone: watchViewModel.getTimeZone(for: watch.name),
                                size: min(geometry.size.width * 0.75, 280)
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: min(geometry.size.width * 0.75, 280) + 40)
                    
                    // Pager indicator below watch
                    if watchViewModel.selectedWatches.count > 0 {
                        Text("\(selectedWatchIndex + 1) / \(watchViewModel.selectedWatches.count)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 4)
                    }
                    
                    // World map
                    CustomWorldMapWithDayNight()
                        .padding(.top, 8)
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .sheet(isPresented: $showingTimeZonePicker) {
            WatchTimeZonePickerView(
                watchName: currentWatch?.name ?? "",
                currentTimeZone: currentWatchTimeZone,
                onTimeZoneSelected: { newTimeZone in
                    if let watch = currentWatch {
                        watchViewModel.saveTimeZone(newTimeZone, for: watch.name)
                    }
                }
            )
            .environmentObject(timeZoneViewModel)
        }
    }
}

// MARK: - Watch-specific Time Zone Picker
struct WatchTimeZonePickerView: View {
    let watchName: String
    let currentTimeZone: TimeZone
    let onTimeZoneSelected: (TimeZone) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var timeZoneViewModel: TimeZoneViewModel
    
    @State private var searchText = ""
    
    var filteredTimeZones: [TimeZoneInfo] {
        if searchText.isEmpty {
            return timeZoneViewModel.availableTimeZones
        } else {
            return timeZoneViewModel.availableTimeZones.filter { timeZone in
                timeZone.displayName.localizedCaseInsensitiveContains(searchText) ||
                timeZone.id.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Title section
                if !watchName.isEmpty {
                    Section {
                        Text("Set time zone for **\(watchName)**")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Popular time zones section
                if searchText.isEmpty {
                    Section("Popular") {
                        ForEach(timeZoneViewModel.popularTimeZones, id: \.id) { timeZoneInfo in
                            WatchTimeZoneRow(
                                timeZoneInfo: timeZoneInfo,
                                isSelected: timeZoneInfo.id == currentTimeZone.identifier
                            ) {
                                if let tz = TimeZone(identifier: timeZoneInfo.id) {
                                    onTimeZoneSelected(tz)
                                }
                                dismiss()
                            }
                        }
                    }
                }
                
                // All time zones section
                Section("All Time Zones") {
                    ForEach(filteredTimeZones, id: \.id) { timeZoneInfo in
                        WatchTimeZoneRow(
                            timeZoneInfo: timeZoneInfo,
                            isSelected: timeZoneInfo.id == currentTimeZone.identifier
                        ) {
                            if let tz = TimeZone(identifier: timeZoneInfo.id) {
                                onTimeZoneSelected(tz)
                            }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Time Zone")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search time zones...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Watch Time Zone Row
struct WatchTimeZoneRow: View {
    let timeZoneInfo: TimeZoneInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(timeZoneInfo.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(timeZoneInfo.id)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State
struct EmptyWatchesView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "clock.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 8) {
                Text("No Watches Selected")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Add some luxury timepieces to get started")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: WatchListView()) {
                HStack {
                    Image(systemName: "watchface.applewatch.case")
                    Text("Browse Watches")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                )
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
#Preview("With Watches") {
    NavigationView {
        TimeView()
    }
    .environmentObject({
        let vm = WatchViewModel()
        vm.selectedWatches = [
            WatchInfo.allWatches[0],
            WatchInfo.allWatches[1],
            WatchInfo.allWatches[2]
        ]
        return vm
    }())
    .environmentObject(ThemeViewModel())
    .environmentObject(TimeZoneViewModel())
}

#Preview("Empty State") {
    NavigationView {
        TimeView()
    }
    .environmentObject(WatchViewModel())
    .environmentObject(ThemeViewModel())
    .environmentObject(TimeZoneViewModel())
}
