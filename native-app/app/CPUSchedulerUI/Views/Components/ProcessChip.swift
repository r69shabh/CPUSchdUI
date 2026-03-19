import SwiftUI

// MARK: - Process Chip (small tag)
struct ProcessChip: View {
    let name: String
    let color: Color
    var isActive: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color.gradient)
                .frame(width: 8, height: 8)

            Text(name)
                .font(.caption.bold())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(isActive ? 0.25 : 0.1))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .strokeBorder(color.opacity(isActive ? 0.6 : 0.2), lineWidth: 1)
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundStyle(color)

            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

// MARK: - Info Badge
struct InfoBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
    }
}
