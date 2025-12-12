import SwiftUI

// About view showing app information (equivalent to Android AboutScreen)
struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // App icon and title
                VStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 80))
                       // .foregroundStyle(.accent)
                    
                    Text("Swiss Time")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Luxury Watch Faces")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                // Version info
                VStack(spacing: 8) {
                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Built with SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("About Swiss Time")
                        .font(.headline)
                    
                    Text("World Clock with timezones is a mighty little app that adds fun to timekeeping. Ditch boring digital clock faces and instead use intricate mechanical watchfaces.")
                        .font(.body)
                        .lineSpacing(4)
                    
                    Text("Experience luxury timepieces from prestigious brands including Swiss, German, Russian, and Japanese manufacturers. Each watch face is carefully crafted to represent the authentic design and heritage of these renowned watchmakers.")
                        .font(.body)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("Features")
                        .font(.headline)
                    
                    FeatureListItem(
                        icon: "watchface.applewatch.case",
                        title: "19 Luxury Watch Faces",
                        description: "Authentic designs from prestigious brands"
                    )
                    
                    FeatureListItem(
                        icon: "globe",
                        title: "Multiple Time Zones",
                        description: "Track time across different regions"
                    )
                    
                    FeatureListItem(
                        icon: "paintbrush",
                        title: "Customizable Themes",
                        description: "Light, dark, and system appearance"
                    )
                    
                    FeatureListItem(
                        icon: "gear",
                        title: "Flexible Settings",
                        description: "US/International time formats and more"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Credits
                VStack(alignment: .leading, spacing: 16) {
                    Text("Credits")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Original Android App")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Built with Jetpack Compose and modern Android architecture")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SwiftUI Migration")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Migrated to native SwiftUI with iOS design patterns")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Links section
                VStack(spacing: 16) {
                    Button(action: openAppStore) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Rate on App Store")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                     //   .background(.accent, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: contactSupport) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Contact Support")
                        }
                        .font(.subheadline)
                //        .foregroundColor(.accent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                  //              .stroke(.accent, lineWidth: 1)
                        )
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func openAppStore() {
        // TODO: Open App Store page
        print("Opening App Store...")
    }
    
    private func contactSupport() {
        // TODO: Open email composer or support form
        print("Opening support contact...")
    }
}

// MARK: - Feature List Item
struct FeatureListItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AboutView()
    }
}
