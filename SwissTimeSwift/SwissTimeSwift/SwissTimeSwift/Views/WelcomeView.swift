import SwiftUI

  // Welcome/onboarding view shown when no watches are selected (equivalent to Android WelcomeScreen)
  struct WelcomeView: View {
      @EnvironmentObject var watchViewModel: WatchViewModel
      @State private var currentWatchIndex = 0

      var body: some View {
          GeometryReader { geometry in
              ScrollView(.vertical) {
                  VStack(spacing: 32) {
                      Spacer(minLength: 20)

                      // Header section
                      VStack(spacing: 16) {
                          Image(systemName: "clock.badge.plus")
                              .font(.system(size: 80))
                              .foregroundColor(.blue)

                          Text("Welcome to Swiss Time")
                              .font(.largeTitle)
                              .fontWeight(.bold)
                              .multilineTextAlignment(.center)

                          Text("Experience luxury timepieces from around the world")
                              .font(.title3)
                              .foregroundColor(.secondary)
                              .multilineTextAlignment(.center)
                              .padding(.horizontal)
                      }

                      // Watch Pager
                      VStack(spacing: 20) {
                          Text("Swipe to explore watch faces")
                              .font(.headline)
                              .foregroundColor(.secondary)

                          WatchPagerView(
                              watches: WatchInfo.allWatches,
                              currentIndex: $currentWatchIndex,
                              geometry: geometry
                          )

                          // Current watch info
                          VStack(spacing: 8) {
                              Text(WatchInfo.allWatches[currentWatchIndex].name)
                                  .font(.title2)
                                  .fontWeight(.medium)
                                  .multilineTextAlignment(.center)

                              Text(WatchInfo.allWatches[currentWatchIndex].description)
                                  .font(.subheadline)
                                  .foregroundColor(.secondary)
                                  .multilineTextAlignment(.center)
                                  .lineLimit(3)
                                  .padding(.horizontal)
                          }

                          // Page indicator
                          HStack(spacing: 6) {
                              ForEach(0..<WatchInfo.allWatches.count, id: \.self) { index in
                                  Circle()
                                      .fill(index == currentWatchIndex ? Color.blue : Color.gray.opacity(0.3))
                                      .frame(width: 6, height: 6)
                                      .animation(.easeInOut(duration: 0.2), value: currentWatchIndex)
                              }
                          }
                          .padding(.top, 8)
                      }

                      // Call to action
                      VStack(spacing: 20) {
                          Text("Get started by selecting your favorite watch faces")
                              .font(.title2)
                              .fontWeight(.medium)
                              .multilineTextAlignment(.center)
                              .padding(.horizontal)

                          NavigationLink(destination: WatchListView()) {
                              HStack {
                                  Image(systemName: "watchface.applewatch.case")
                                  Text("Browse Watch Collection")
                              }
                              .font(.headline)
                              .foregroundColor(.white)
                              .padding()
                              .frame(maxWidth: .infinity)
                              .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                              .padding(.horizontal, 32)
                          }

                          // Quick add button for current watch
                          Button(action: {
                              let currentWatch = WatchInfo.allWatches[currentWatchIndex]
                              watchViewModel.addWatch(currentWatch)
                          }) {
                              HStack {
                                  Image(systemName: "plus.circle")
                                  Text("Add This Watch to Collection")
                              }
                              .font(.subheadline)
                              .foregroundColor(.blue)
                              .padding()
                              .frame(maxWidth: .infinity)
                              .overlay(
                                  RoundedRectangle(cornerRadius: 12)
                                      .stroke(Color.blue, lineWidth: 1)
                              )
                              .padding(.horizontal, 32)
                          }
                      }

                      // Features list
                      VStack(alignment: .leading, spacing: 16) {
                          FeatureRow(
                              icon: "globe",
                              title: "Multiple Time Zones",
                              description: "Track time across different regions"
                          )

                          FeatureRow(
                              icon: "paintbrush",
                              title: "Luxury Watch Faces",
                              description: "Authentic designs from prestigious brands"
                          )

                          FeatureRow(
                              icon: "gear",
                              title: "Customizable Settings",
                              description: "Personalize your timekeeping experience"
                          )
                      }
                      .padding(.horizontal, 32)

                      Spacer(minLength: 100) // Extra space for tab bar
                  }
                  .frame(maxWidth: .infinity)
                  .padding(.horizontal)
              }
          }
          .navigationTitle("Welcome")
          .navigationBarTitleDisplayMode(.inline)
      }
  }

  // MARK: - Watch Pager View
  struct WatchPagerView: View {
      let watches: [WatchInfo]
      @Binding var currentIndex: Int
      let geometry: GeometryProxy

      private let watchSize: CGFloat = 250

      var body: some View {
          ScrollViewReader { proxy in
              ScrollView(.horizontal) {
                  LazyHStack(spacing: 0) {
                      ForEach(Array(watches.enumerated()), id: \.element.id) { index, watch in
                          VStack(spacing: 16) {
                              WatchFaceView(
                                  watch: watch,
                                  timeZone: TimeZone.current,
                                  size: watchSize
                              )
                              .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                          }
                          .containerRelativeFrame(.horizontal)
                          .id(index)
                          .onTapGesture {
                              // Animate to center if not already centered
                              if index != currentIndex {
                                  withAnimation(.easeInOut(duration: 0.5)) {
                                      proxy.scrollTo(index, anchor: .center)
                                  }
                              }
                          }
                      }
                  }
                  .scrollTargetLayout()
              }
              .scrollTargetBehavior(.paging)
              .scrollIndicators(.hidden)
              .frame(height: watchSize + 40)
              .onScrollTargetVisibilityChange(idType: Int.self) { visibleIDs in
                  if let firstVisible = visibleIDs.first {
                      withAnimation(.easeInOut(duration: 0.2)) {
                          currentIndex = firstVisible
                      }
                  }
              }
          }
      }
  }

  // MARK: - Feature Row
  struct FeatureRow: View {
      let icon: String
      let title: String
      let description: String

      var body: some View {
          HStack(spacing: 16) {
              Image(systemName: icon)
                  .font(.title2)
                  .foregroundColor(.blue)
                  .frame(width: 30)

              VStack(alignment: .leading, spacing: 4) {
                  Text(title)
                      .font(.headline)

                  Text(description)
                      .font(.subheadline)
                      .foregroundColor(.secondary)
              }

              Spacer()
          }
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

