import SwiftUI

// MARK: - Animated Button Style
struct AnimatedButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .shadow(color: color.opacity(0.3), radius: configuration.isPressed ? 2 : 6, y: configuration.isPressed ? 1 : 3)
    }
}

// MARK: - Pill Button
struct PillButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(AnimatedButtonStyle(color: color))
    }
}
