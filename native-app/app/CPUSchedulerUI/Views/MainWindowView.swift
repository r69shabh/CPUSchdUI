import SwiftUI

// MARK: - Main Window View
struct MainWindowView: View {
    @EnvironmentObject private var preferences: PreferencesService

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
            case .education: return "book.closed"
            }
        }

        var subtitle: String {
            switch self {
            case .simulator: return "Run manual or live snapshot what-if scheduling"
            case .comparison: return "Compare algorithm tradeoffs on one snapshot"
            case .monitor: return "Observe real process activity"
            case .education: return "Interactive lessons and quizzes"
            }
        }

        var keyboardHint: String {
            switch self {
            case .simulator: return "1"
            case .comparison: return "2"
            case .monitor: return "3"
            case .education: return "4"
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
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.quaternary)
                            .frame(width: 38, height: 38)
                        Image(systemName: "cpu.fill")
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("CPU Scheduler")
                            .font(.headline)
                        Text("macOS Learning Studio")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if preferences.showTooltips {
                    Label("Hover cards and labels for live explanations", systemImage: "lightbulb")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            Divider()

            List(selection: $selectedTab) {
                Section("Workspace") {
                    ForEach(Tab.allCases) { tab in
                        HStack(spacing: 10) {
                            Image(systemName: tab.icon)
                                .frame(width: 18)
                                .foregroundStyle(selectedTab == tab ? Color.accentColor : .secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tab.rawValue)
                                    .font(.body.weight(.medium))
                                Text(tab.subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(tab.keyboardHint)
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                        .tag(tab)
                    }
                }
            }
            .listStyle(.sidebar)

            Divider()

            learningSpotlight
                .padding(12)
        }
        .navigationSplitViewColumnWidth(min: 225, ideal: 255, max: 290)
    }

    private var learningSpotlight: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Learning Spotlight", systemImage: "sparkles")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(spotlightTitle)
                .font(.subheadline.weight(.semibold))

            Text(spotlightBody)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Button {
                selectedTab = .education
            } label: {
                Label("Open Learn", systemImage: "arrow.right")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.link)
            .help("Jump to the interactive learning section")
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var spotlightTitle: String {
        switch selectedTab {
        case .simulator:
            return "Watch Context Switches"
        case .comparison:
            return "Find the Best Tradeoff"
        case .monitor:
            return "Real Process Behavior"
        case .education:
            return "Knowledge Check"
        }
    }

    private var spotlightBody: String {
        switch selectedTab {
        case .simulator:
            return "Use Live Snapshot controls to map real processes into what-if arrivals and bursts, then inspect popovers."
        case .comparison:
            return "Compare the same live process set across algorithms and inspect the baseline card for modeling assumptions."
        case .monitor:
            return "Sort by CPU and inspect per-process memory and thread counts from live system data."
        case .education:
            return "Complete modules and quizzes to reinforce FCFS, SJF, RR, and Priority behavior."
        }
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
