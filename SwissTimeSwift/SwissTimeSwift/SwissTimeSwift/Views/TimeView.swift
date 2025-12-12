import SwiftUI

// Main time display view showing selected watch faces (equivalent to Android TimeScreen)
struct TimeView: View {
    @EnvironmentObject var watchViewModel: WatchViewModel
    @EnvironmentObject var timeZoneViewModel: TimeZoneViewModel
    
    @State private var currentTime = Date()
    @State private var selectedWatchIndex = 0
    
    // Timer for updating time
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            if watchViewModel.selectedWatches.isEmpty {
                // Show empty state if no watches selected
                EmptyWatchesView()
            } else {
                // Show watch faces in pager
                WatchFacePager(
                    watches: watchViewModel.selectedWatches,
                    selectedIndex: $selectedWatchIndex,
                    geometry: geometry
                )
            }
        }
        .navigationTitle("Swiss Time")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !watchViewModel.selectedWatches.isEmpty {
                    Menu {
                        Button("Settings") {
                            // Navigate to settings
                        }
                        Button("Add Watches") {
                            // Navigate to watch list
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// MARK: - Watch Face Pager
struct WatchFacePager: View {
    let watches: [WatchInfo]
    @Binding var selectedIndex: Int
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 20) {
            // Current watch info
            VStack(spacing: 8) {
                Text(watches[selectedIndex].name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text("\(selectedIndex + 1) of \(watches.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Watch face display
            TabView(selection: $selectedIndex) {
                ForEach(Array(watches.enumerated()), id: \.element.id) { index, watch in
                    WatchFaceView(
                        watch: watch,
                        timeZone: TimeZone.current, // TODO: Use watch-specific timezone
                        size: min(geometry.size.width * 0.8, 350)
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: min(geometry.size.width * 0.8, 350) + 50)
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<watches.count, id: \.self) { index in
                    Circle()
                    //    .fill(index == selectedIndex ? .accent : .secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                }
            }
            
            // Watch description
            Text(watches[selectedIndex].description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}

// MARK: - Empty State
struct EmptyWatchesView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "clock.badge.plus")
                .font(.system(size: 80))
           //     .foregroundStyle(.accent)
            
            VStack(spacing: 8) {
                Text("No Watches Selected")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Add some luxury timepieces to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
             //   .background(.accent, in: RoundedRectangle(cornerRadius: 12))
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
