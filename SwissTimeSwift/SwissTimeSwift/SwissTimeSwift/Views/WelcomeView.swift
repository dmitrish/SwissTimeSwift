import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var watchViewModel: WatchViewModel
    
    // Start at the middle watch (19 watches total, so middle is index 9)
    @State private var currentWatchIndex = 9
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
                        .padding(.top, 2)
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 4
                )
                
                // Watch section - anchored from BOTTOM
                VStack(spacing: 0) {
                    Spacer() // Push everything to the bottom
                    
                    VStack(spacing: 20) {
                        // Current watch info ABOVE the watch
                        VStack(spacing: 8) {
                            Text(WatchInfo.allWatches[currentWatchIndex].name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(WatchInfo.allWatches[currentWatchIndex].description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(height: 70, alignment: .bottom)
                        .padding(.horizontal, 20)
                        
                        // Watch Pager
                        WatchPagerView(
                            watches: WatchInfo.allWatches,
                            currentIndex: $currentWatchIndex,
                            geometry: geometry,
                            isZoomed: $isZoomed
                        )
                        
                        // Tap to zoom / Select button
                        Group {
                            if isZoomed {
                                Button(action: {
                                    let selectedWatch = WatchInfo.allWatches[currentWatchIndex]
                                    watchViewModel.addWatch(selectedWatch)
                                    
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
                        .frame(height: 44)
                    }
                    .padding(.bottom, geometry.size.height / 4 - 150)
                }
            }
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar) // Add this line to hide the tab bar
    }
}
