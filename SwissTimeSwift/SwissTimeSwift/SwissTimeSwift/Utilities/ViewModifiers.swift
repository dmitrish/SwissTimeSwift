import SwiftUI


struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color("SwissTimePrimary")
                .ignoresSafeArea()
            content
        }
    }
}


extension View {
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}
