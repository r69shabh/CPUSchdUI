import SwiftUI

// MARK: - Loading Spinner
struct LoadingSpinner: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .foregroundStyle(Color.secondary.opacity(0.2))
                .frame(width: 32, height: 32)

            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .foregroundStyle(.blue.gradient)
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        }
    }
}

// MARK: - Pulse Dot
struct PulseDot: View {
    let color: Color
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                    scale = 1.5
                }
            }
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.15), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 400
                    }
                }
            }
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
