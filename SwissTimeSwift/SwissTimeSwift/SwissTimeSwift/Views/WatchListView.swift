import SwiftUI

// Watch collection view matching Android WatchListScreen design
struct WatchListView: View {
    @EnvironmentObject var watchViewModel: WatchViewModel
    @State private var searchText = ""
    @State private var showingSelectedOnly = false
    
    var filteredWatches: [WatchInfo] {
        let watches = showingSelectedOnly ? watchViewModel.selectedWatches : watchViewModel.availableWatches
        
        if searchText.isEmpty {
            return watches
        } else {
            return watches.filter { watch in
                watch.name.localizedCaseInsensitiveContains(searchText) ||
                watch.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter toggle bar
            HStack {
                Button(action: { showingSelectedOnly.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: showingSelectedOnly ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(showingSelectedOnly ? .white : .white.opacity(0.7))
                        Text("Show Selected Only")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .font(.subheadline)
                }
                
                Spacer()
                
                Text("\(watchViewModel.selectedWatches.count) selected")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Watch list (not grid - matching Android)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredWatches) { watch in
                        WatchListRowContent(
                            watch: watch,
                            isSelected: watchViewModel.isWatchSelected(watch),
                            onToggleSelection: {
                                _ = watchViewModel.toggleWatchSelection(watch)
                            }
                        )
                    }
                }
                .padding(.bottom, 100) // Space for tab bar
            }
        }
        .navigationTitle("Watches")
        .searchable(text: $searchText, prompt: "Search watches...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Select All") {
                        for watch in watchViewModel.availableWatches {
                            if !watchViewModel.isWatchSelected(watch) {
                                watchViewModel.addWatch(watch)
                            }
                        }
                    }
                    
                    Button("Clear Selection") {
                        watchViewModel.clearAllSelectedWatches()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .appBackground()
    }
}

// MARK: - Watch List Row Content
struct WatchListRowContent: View {
    let watch: WatchInfo
    let isSelected: Bool
    let onToggleSelection: () -> Void
    
    @EnvironmentObject var watchViewModel: WatchViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Tappable area for navigation (watch face + info)
            NavigationLink(destination: WatchDetailView(watch: watch)) {
                HStack(alignment: .top, spacing: 16) {
                    // Watch face preview (left side) - uses watch's own time zone
                    WatchFaceView(
                        watch: watch,
                        timeZone: watchViewModel.getTimeZone(for: watch.name),
                        size: 70
                    )
                    
                    // Watch info (center)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(watch.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(watch.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
            
            // Selection icon (right side) - separate tap target
            Button(action: onToggleSelection) {
                Image(systemName: isSelected ? "checkmark" : "arrow.up.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                    .frame(width: 44, height: 44) // Larger tap target
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.leading, 20)
        .padding(.trailing, 12)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        WatchListView()
            .environmentObject({
                let vm = WatchViewModel()
                vm.selectedWatches = [WatchInfo.allWatches[0], WatchInfo.allWatches[1]]
                return vm
            }())
    }
}
