import SwiftUI

// MARK: - Watch Card Component
struct WatchCard: View {
    let watch: WatchInfo
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let onTapWatch: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Watch face preview
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .aspectRatio(1, contentMode: .fit)
                
                WatchFaceView(
                    watch: watch,
                    timeZone: TimeZone.current,
                    size: 120
                )
                .onTapGesture {
                    onTapWatch()
                }
            }
            
            // Watch info
            VStack(spacing: 4) {
                Text(watch.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(watch.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Selection button
            Button(action: onToggleSelection) {
                HStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    Text(isSelected ? "Selected" : "Select")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                    //    .fill(isSelected ? .accentColor : .clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                     //           .stroke(.accentColor, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

