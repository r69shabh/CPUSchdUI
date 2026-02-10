import SwiftUI

// MARK: - Glass Card (Frosted Glass / Material Background)
struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Elevated Card
struct ElevatedCard<Content: View>: View {
    var cornerRadius: CGFloat = 14
    let content: () -> Content

    init(cornerRadius: CGFloat = 14, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
