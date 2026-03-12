import SwiftUI

// MARK: - App Color Palette
struct AppColors {
    static let primary = Color.accentColor
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // Algorithm-specific colors (vibrant, distinct)
    static let fcfs = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let sjf = Color(red: 0.9, green: 0.4, blue: 0.2)
    static let srtf = Color(red: 0.5, green: 0.8, blue: 0.3)
    static let roundRobin = Color(red: 0.7, green: 0.3, blue: 0.9)
    static let priorityNP = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let priorityP = Color(red: 0.3, green: 0.7, blue: 0.8)

    // Gradient helpers
    static func algorithmGradient(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - App Fonts
struct AppFonts {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let monospacedDigit = Font.system(.body, design: .monospaced)
}
