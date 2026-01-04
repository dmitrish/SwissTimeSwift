import SwiftUI

// Watch detail screen with expand/collapse animation matching Android design
struct WatchDetailView: View {
    let watch: WatchInfo
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var watchViewModel: WatchViewModel
    
    // Animation state
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            // Main content - watch centered with offset, text positioned separately
            ZStack {
                VStack {
                    Spacer()
                    
                    // Watch face - centered horizontally, offset vertically
                    ZStack {
                        // Glow effect layer (only when expanded)
                        if isExpanded {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.08),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 150,
                                        endRadius: 280
                                    )
                                )
                                .frame(width: 560, height: 560)
                                .transition(.opacity)
                        }
                        
                        // Watch face
                        WatchFaceView(
                            watch: watch,
                            timeZone: watchViewModel.getTimeZone(for: watch.name),
                            size: 250
                        )
                        .scaleEffect(isExpanded ? 1.8 : 1.0)
                    }
                    .offset(y: isExpanded ? 0 : -150) // Move up when collapsed
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }
                    
                    Spacer()
                }
                
                // Text content - positioned below center with scrollable description
                if !isExpanded {
                    VStack {
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height * 0.48)
                        
                        // Watch name - fixed
                        Text(watch.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        // Scrollable description
                        ScrollView {
                            Text(watch.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 32)
                                .padding(.top, 32)
                        }
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.42)
                        
                        Spacer()
                            .frame(height: 80) // Space for tab bar
                    }
                    .transition(.opacity)
                }
            }
            
            // Overlay to capture taps when expanded (outside the watch)
            if isExpanded {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }
                    .allowsHitTesting(true)
            }
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) {
            // Custom back button without toolbar styling
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left")
                    Text("Back to list")
                }
                .foregroundColor(.white)
                .font(.body)
            }
            .padding(.leading, 16)
            .padding(.top, 8)
            .opacity(isExpanded ? 0 : 1)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        WatchDetailView(watch: WatchInfo.allWatches[7]) // Roma Marina
            .environmentObject(WatchViewModel())
    }
}
