import SwiftUI
import Charts

// MARK: - Comparison View
struct ComparisonView: View {
    @StateObject private var viewModel = ComparisonViewModel()
    @State private var showingScenarios = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            comparisonToolbar

            Divider()

            if viewModel.results.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Bar charts comparison
                        metricsComparisonCharts
                            .padding(.horizontal, 24)

                        Divider()
                            .padding(.horizontal, 24)

                        // Side-by-side Gantt charts
                        sideBySideGantt
                            .padding(.horizontal, 24)

                        // Detailed comparison table
                        comparisonTable
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingScenarios) {
            ComparisonScenarioSheet(viewModel: viewModel)
        }
    }

    // MARK: - Toolbar
    private var comparisonToolbar: some View {
        HStack(spacing: 16) {
            Label("Algorithm Comparison", systemImage: "chart.bar.xaxis")
                .font(.headline)

            Spacer()

            // Algorithm toggles
            HStack(spacing: 6) {
                ForEach(AlgorithmInfo.all) { algo in
                    Toggle(isOn: Binding(
                        get: { viewModel.selectedAlgorithms.contains(algo.id) },
                        set: { _ in viewModel.toggleAlgorithm(algo) }
                    )) {
                        Text(algo.shortName)
                            .font(.caption2.bold())
                    }
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                    .tint(algo.color)
                    .controlSize(.small)
                }
            }

            Divider()
                .frame(height: 24)

            Menu {
                Button(action: { showingScenarios = true }) {
                    Label("Load Scenario", systemImage: "folder")
                }
                Button(action: { viewModel.generateRandomProcesses() }) {
                    Label("Generate Random", systemImage: "dice")
                }
            } label: {
                Label("Processes", systemImage: "square.and.arrow.down")
                    .font(.subheadline)
            }
            .menuStyle(.borderlessButton)

            Button(action: { viewModel.runComparison() }) {
                Label("Compare", systemImage: "play.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.processes.isEmpty || viewModel.selectedAlgorithms.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.purple.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 48))
                    .foregroundStyle(.purple.opacity(0.6))
            }

            VStack(spacing: 8) {
                Text("Compare Algorithms")
                    .font(.title.bold())

                Text("Select algorithms, load processes, and run\na side-by-side comparison")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                Button("Load Scenario") { showingScenarios = true }
                    .buttonStyle(.bordered)

                Button("Random Processes") { viewModel.generateRandomProcesses() }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
            }

            if !viewModel.processes.isEmpty {
                VStack(spacing: 8) {
                    Text("\(viewModel.processes.count) processes loaded")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        ForEach(viewModel.processes) { p in
                            ProcessChip(name: p.name, color: p.color)
                        }
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Metrics Comparison Charts
    private var metricsComparisonCharts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics Comparison")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
            ], spacing: 16) {
                comparisonBarChart(
                    title: "Avg Turnaround Time",
                    keyPath: \.averageTurnaroundTime,
                    unit: "units",
                    lowerIsBetter: true
                )

                comparisonBarChart(
                    title: "Avg Waiting Time",
                    keyPath: \.averageWaitingTime,
                    unit: "units",
                    lowerIsBetter: true
                )

                comparisonBarChart(
                    title: "CPU Utilization",
                    keyPath: \.cpuUtilization,
                    unit: "%",
                    lowerIsBetter: false
                )

                comparisonBarChart(
                    title: "Throughput",
                    keyPath: \.throughput,
                    unit: "proc/unit",
                    lowerIsBetter: false
                )
            }
        }
    }

    private func comparisonBarChart(title: String, keyPath: KeyPath<PerformanceMetrics, Double>, unit: String, lowerIsBetter: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: lowerIsBetter ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.caption)
                    .foregroundStyle(lowerIsBetter ? .green : .blue)
            }

            Chart(viewModel.results) { result in
                BarMark(
                    x: .value("Algorithm", result.algorithm.shortName),
                    y: .value("Value", result.metrics[keyPath: keyPath])
                )
                .foregroundStyle(result.algorithm.color.gradient)
                .cornerRadius(6)
                .annotation(position: .top) {
                    Text(String(format: "%.1f", result.metrics[keyPath: keyPath]))
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxisLabel(unit)
            .frame(height: 160)

            // Best indicator
            if let best = bestResult(keyPath: keyPath, lowerIsBetter: lowerIsBetter) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text("Best: \(best.algorithm.shortName)")
                        .font(.caption2.bold())
                        .foregroundStyle(best.algorithm.color)
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func bestResult(keyPath: KeyPath<PerformanceMetrics, Double>, lowerIsBetter: Bool) -> SchedulingResult? {
        if lowerIsBetter {
            return viewModel.results.min { $0.metrics[keyPath: keyPath] < $1.metrics[keyPath: keyPath] }
        } else {
            return viewModel.results.max { $0.metrics[keyPath: keyPath] < $1.metrics[keyPath: keyPath] }
        }
    }

    // MARK: - Side-by-Side Gantt
    private var sideBySideGantt: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timeline Comparison")
                .font(.headline)

            ForEach(viewModel.results) { result in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(result.algorithm.color.gradient)
                            .frame(width: 10, height: 10)
                        Text(result.algorithm.name)
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text("Total: \(result.metrics.totalTime) units")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Chart(result.timeline) { event in
                        BarMark(
                            xStart: .value("Start", event.startTime),
                            xEnd: .value("End", event.endTime),
                            y: .value("Process", event.processName)
                        )
                        .foregroundStyle(event.color.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    }
                    .chartXAxisLabel("Time Units")
                    .frame(height: CGFloat(Set(result.timeline.map(\.processName)).count) * 32 + 30)
                }
                .padding(16)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    // MARK: - Comparison Table
    private var comparisonTable: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Summary Table")
                .font(.headline)

            VStack(spacing: 1) {
                // Header
                HStack(spacing: 0) {
                    Text("Algorithm")
                        .frame(width: 130, alignment: .leading)
                    Text("Avg TAT")
                        .frame(width: 80)
                    Text("Avg Wait")
                        .frame(width: 80)
                    Text("Avg Resp")
                        .frame(width: 80)
                    Text("CPU %")
                        .frame(width: 70)
                    Text("Switches")
                        .frame(width: 80)
                }
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.secondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                ForEach(viewModel.results) { result in
                    HStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(result.algorithm.color.gradient)
                                .frame(width: 8, height: 8)
                            Text(result.algorithm.shortName)
                                .font(.caption.bold())
                        }
                        .frame(width: 130, alignment: .leading)

                        Text(String(format: "%.2f", result.metrics.averageTurnaroundTime))
                            .frame(width: 80)
                        Text(String(format: "%.2f", result.metrics.averageWaitingTime))
                            .frame(width: 80)
                        Text(String(format: "%.2f", result.metrics.averageResponseTime))
                            .frame(width: 80)
                        Text(String(format: "%.1f%%", result.metrics.cpuUtilization))
                            .frame(width: 70)
                        Text("\(result.metrics.contextSwitches)")
                            .frame(width: 80)
                    }
                    .font(.system(.caption, design: .monospaced))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        viewModel.results.firstIndex(where: { $0.id == result.id }).map { $0 % 2 == 0 } ?? false
                            ? Color(nsColor: .controlBackgroundColor).opacity(0.5)
                            : Color.clear
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
            }
        }
    }
}

// MARK: - Comparison Scenario Sheet
struct ComparisonScenarioSheet: View {
    @ObservedObject var viewModel: ComparisonViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedScenario: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Load Scenario for Comparison")
                    .font(.title2.bold())
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

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(MockDataService.scenarios, id: \.name) { scenario in
                        ScenarioRow(
                            name: scenario.name,
                            processes: scenario.processes,
                            isSelected: selectedScenario == scenario.name
                        )
                        .onTapGesture {
                            withAnimation { selectedScenario = scenario.name }
                        }
                    }
                }
                .padding(16)
            }

            Divider()

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button(action: {
                    if let name = selectedScenario,
                       let scenario = MockDataService.scenarios.first(where: { $0.name == name }) {
                        viewModel.loadScenario(scenario.processes)
                    }
                    dismiss()
                }) {
                    Label("Load", systemImage: "arrow.down.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedScenario == nil)
            }
            .padding(20)
        }
        .frame(width: 520, height: 480)
    }
}
