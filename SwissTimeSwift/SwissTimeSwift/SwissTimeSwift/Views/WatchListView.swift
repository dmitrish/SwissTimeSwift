import SwiftUI

// Watch collection view showing all available watches (equivalent to Android WatchListScreen)
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
        NavigationView {
            VStack(spacing: 0) {
                // Filter toggle
                HStack {
                    Button(action: { showingSelectedOnly.toggle() }) {
                        HStack {
                            Image(systemName: showingSelectedOnly ? "checkmark.circle.fill" : "circle")
                            Text("Show Selected Only")
                        }
                        .font(.subheadline)
                        .foregroundColor(showingSelectedOnly ? .accentColor : .primary)
                    }
                    
                    Spacer()
                    
                    Text("\(watchViewModel.selectedWatches.count) selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Watch grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredWatches) { watch in
                            WatchCard(
                                watch: watch,
                                isSelected: watchViewModel.isWatchSelected(watch),
                                onToggleSelection: {
                                    let wasAdded = watchViewModel.toggleWatchSelection(watch)
                                    // TODO: Show toast message
                                },
                                onTapWatch: {
                                    // Navigate to detail view
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Space for tab bar
                }
            }
        }
        .navigationTitle("Watch Collection")
        .searchable(text: $searchText, prompt: "Search watches...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Select All") {
                        // Add all watches
                        for watch in watchViewModel.availableWatches {
                            if !watchViewModel.isWatchSelected(watch) {
                                watchViewModel.addWatch(watch)
                            }
                        }
                    }
                    
                    Button("Clear Selection") {
                        watchViewModel.clearAllSelectedWatches()
                    }
                    
                    Divider()
                    
                    Button("Sort by Name") {
                        // TODO: Implement sorting
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    WatchListView()
        .environmentObject({
            let vm = WatchViewModel()
            vm.selectedWatches = [WatchInfo.allWatches[0], WatchInfo.allWatches[1]]
            return vm
        }())
}
