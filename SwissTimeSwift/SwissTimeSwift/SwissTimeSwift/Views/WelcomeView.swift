import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var watchViewModel: WatchViewModel
    @State private var currentWatchIndex = 0
    @State private var isZoomed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Header section at 1/4 from top
                VStack(spacing: 16) {
                    Image(systemName: "clock.badge.plus")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Let's get started!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose your first watch")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 4
                )
                
                // Watch Pager positioned at 1/4 from bottom
                VStack(spacing: 20) {
                    // Current watch info ABOVE the watch
                    VStack(spacing: 8) {
                        Text(WatchInfo.allWatches[currentWatchIndex].name)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        Text(WatchInfo.allWatches[currentWatchIndex].description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            // REMOVED .padding(.horizontal) to eliminate left margin
                    }
                    .padding(.horizontal, 16) // Apply padding to the entire VStack instead
                    
                    // Watch Pager - zoom is now handled WITHOUT layout shift
                    WatchPagerView(
                        watches: WatchInfo.allWatches,
                        currentIndex: $currentWatchIndex,
                        geometry: geometry,
                        isZoomed: $isZoomed
                    )
                    
                    // Tap to zoom / Select button - FIXED SPACING
                    Group {
                        if isZoomed {
                            Button(action: {
                                // Add the selected watch to the collection
                                let selectedWatch = WatchInfo.allWatches[currentWatchIndex]
                                watchViewModel.addWatch(selectedWatch)
                                
                                // Reset zoom
                                withAnimation {
                                    isZoomed = false
                                }
                            }) {
                                Text("Select this watch")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 200)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .transition(.opacity)
                        } else {
                            Text("Tap to zoom")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .transition(.opacity)
                        }
                    }
                    .frame(height: 44) // Fixed height so switching doesn't shift layout
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height - (geometry.size.height / 4)
                )
                .padding(.horizontal, 32)
            }
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        WelcomeView()
    }
    .environmentObject(WatchViewModel())
    .environmentObject(ThemeViewModel())
    .environmentObject(TimeZoneViewModel())
}
