import SwiftUI

// MARK: - Scenario Picker Sheet
struct ScenarioPickerSheet: View {
    @ObservedObject var viewModel: SimulatorViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedScenario: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Load Example Scenario")
                        .font(.title2.bold())
                    Text("Choose a pre-configured set of processes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding(24)

            Divider()

            // Scenarios list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(MockDataService.scenarios, id: \.name) { scenario in
                        ScenarioRow(
                            name: scenario.name,
                            processes: scenario.processes,
                            isSelected: selectedScenario == scenario.name
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedScenario = scenario.name
                            }
                        }
                    }
                }
                .padding(16)
            }

            Divider()

            // Actions
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)

                Spacer()

                Button(action: {
                    if let name = selectedScenario,
                       let scenario = MockDataService.scenarios.first(where: { $0.name == name }) {
                        viewModel.loadScenario(scenario.processes)
                    }
                    dismiss()
                }) {
                    Label("Load Scenario", systemImage: "arrow.down.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedScenario == nil)
                .keyboardShortcut(.return)
            }
            .padding(20)
        }
        .frame(width: 520, height: 500)
    }
}

// MARK: - Scenario Row
struct ScenarioRow: View {
    let name: String
    let processes: [SchedulerProcess]
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(name)
                    .font(.headline)

                Spacer()

                Text("\(processes.count) processes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }

            // Process preview chips
            HStack(spacing: 6) {
                ForEach(processes) { process in
                    ProcessChip(name: process.name, color: process.color)
                }
            }

            // Summary
            HStack(spacing: 16) {
                StatBadge(label: "Burst Range", value: "\(processes.map(\.burstTime).min() ?? 0)-\(processes.map(\.burstTime).max() ?? 0)", color: .orange)
                StatBadge(label: "Total Burst", value: "\(processes.reduce(0) { $0 + $1.burstTime })", color: .blue)
            }
        }
        .padding(14)
        .background(isSelected ? Color.blue.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isSelected ? .blue : .clear, lineWidth: 2)
        }
    }
}
