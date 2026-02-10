import SwiftUI

// MARK: - Main Window View
struct MainWindowView: View {
    @State private var selectedTab: Tab = .simulator
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    enum Tab: String, CaseIterable, Identifiable {
        case simulator = "Simulator"
        case comparison = "Comparison"
        case monitor = "System Monitor"
        case education = "Learn"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .simulator: return "cpu"
            case .comparison: return "chart.bar.xaxis"
            case .monitor: return "waveform.path.ecg"
            case .education: return "book.fill"
            }
        }

        var subtitle: String {
            switch self {
            case .simulator: return "Run scheduling algorithms"
            case .comparison: return "Compare algorithms side by side"
            case .monitor: return "View system processes"
            case .education: return "Tutorials & quizzes"
            }
        }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        VStack(spacing: 0) {
            // App branding
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(.linearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 52, height: 52)

                    Image(systemName: "cpu.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.hierarchical)
                }

                Text("CPU Scheduler")
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                Text("Visualizer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)

            Divider()
                .padding(.horizontal)

            // Navigation Items
            List(Tab.allCases, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tab.rawValue)
                                .font(.body.weight(.medium))
                            Text(tab.subtitle)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: tab.icon)
                            .foregroundStyle(selectedTab == tab ? .blue : .secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.sidebar)

            Spacer()

            // Footer
            VStack(spacing: 6) {
                Divider()
                    .padding(.horizontal)

                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.caption2)
                    Text("v1.0.0 · macOS")
                        .font(.caption2)
                }
                .foregroundStyle(.tertiary)
                .padding(.bottom, 12)
            }
        }
        .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 280)
    }

    // MARK: - Detail
    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .simulator:
            SimulatorView()
        case .comparison:
            ComparisonView()
        case .monitor:
            SystemMonitorView()
        case .education:
            EducationView()
        }
    }
}
