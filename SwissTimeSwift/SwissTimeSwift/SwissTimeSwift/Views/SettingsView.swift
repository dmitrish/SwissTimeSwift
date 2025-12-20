import SwiftUI

// Settings view for app preferences (equivalent to Android SettingsScreen)
struct SettingsView: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var timeZoneViewModel: TimeZoneViewModel
    
    @State private var useUSTimeFormat = AppSettings.useUSTimeFormat
    @State private var useDoubleTapForRemoval = AppSettings.useDoubleTapForRemoval
    @State private var showingTimeZonePicker = false
    
    var body: some View {
        Form {
            // Theme section
            Section("Appearance") {
                Picker("Theme", selection: $themeViewModel.themeMode) {
                    ForEach(AppSettings.ThemeMode.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.clear)
            
            // Time format section
            Section("Time Format") {
                Toggle("Use US Time Format (12-hour)", isOn: $useUSTimeFormat)
                    .onChange(of: useUSTimeFormat) { newValue in
                        AppSettings.useUSTimeFormat = newValue
                    }
                
                HStack {
                    Text("Example")
                    Spacer()
                    Text(useUSTimeFormat ? "3:45 PM" : "15:45")
                        .foregroundColor(.secondary)
                }
            }
            .listRowBackground(Color.clear)
            
            // Time zone section
            Section("Time Zone") {
                Button(action: { showingTimeZonePicker = true }) {
                    HStack {
                        Text("Selected Time Zone")
                        Spacer()
                        Text(timeZoneViewModel.selectedTimeZone.localizedName(for: .standard, locale: .current) ?? timeZoneViewModel.selectedTimeZone.identifier)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                
                HStack {
                    Text("Current Time")
                    Spacer()
                    Text(timeZoneViewModel.getFormattedTime(useUSFormat: useUSTimeFormat))
                        .foregroundColor(.secondary)
                }
            }
            .listRowBackground(Color.clear)
            
            // Watch interaction section
            Section("Watch Interaction") {
                Toggle("Double-tap to remove watches", isOn: $useDoubleTapForRemoval)
                    .onChange(of: useDoubleTapForRemoval) { newValue in
                        AppSettings.useDoubleTapForRemoval = newValue
                    }
                
                Text(useDoubleTapForRemoval ? "Double-tap watches to remove them from your collection" : "Long-press watches to remove them from your collection")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .listRowBackground(Color.clear)
            
            // App info section
            Section("About") {
                NavigationLink(destination: AboutView()) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("About Swiss Time")
                    }
                }
                
                HStack {
                    Image(systemName: "star")
                    Text("Rate App")
                }
                .onTapGesture {
                    // TODO: Open App Store rating
                }
                
                HStack {
                    Image(systemName: "envelope")
                    Text("Contact Support")
                }
                .onTapGesture {
                    // TODO: Open email composer
                }
            }
            .listRowBackground(Color.clear)
            
            // Data management section
            Section("Data") {
                Button("Reset All Settings") {
                    // TODO: Show confirmation dialog
                }
                .foregroundColor(.red)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .appBackground()
        .sheet(isPresented: $showingTimeZonePicker) {
            TimeZonePickerView(selectedTimeZone: $timeZoneViewModel.selectedTimeZone)
        }
    }
}

// MARK: - Time Zone Picker
struct TimeZonePickerView: View {
    @Binding var selectedTimeZone: TimeZone
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @EnvironmentObject var timeZoneViewModel: TimeZoneViewModel
    
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
                // Popular time zones section
                if searchText.isEmpty {
                    Section("Popular") {
                        ForEach(timeZoneViewModel.popularTimeZones, id: \.id) { timeZoneInfo in
                            TimeZoneRow(
                                timeZoneInfo: timeZoneInfo,
                                isSelected: timeZoneInfo.id == selectedTimeZone.identifier
                            ) {
                                selectedTimeZone = TimeZone(identifier: timeZoneInfo.id) ?? TimeZone.current
                                dismiss()
                            }
                        }
                    }
                }
                
                // All time zones section
                Section("All Time Zones") {
                    ForEach(filteredTimeZones, id: \.id) { timeZoneInfo in
                        TimeZoneRow(
                            timeZoneInfo: timeZoneInfo,
                            isSelected: timeZoneInfo.id == selectedTimeZone.identifier
                        ) {
                            selectedTimeZone = TimeZone(identifier: timeZoneInfo.id) ?? TimeZone.current
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

// MARK: - Time Zone Row
struct TimeZoneRow: View {
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

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(ThemeViewModel())
        .environmentObject(TimeZoneViewModel())
}
