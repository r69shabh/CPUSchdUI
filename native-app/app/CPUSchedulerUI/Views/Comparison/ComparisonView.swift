import SwiftUI
import Charts

// MARK: - Comparison View
struct ComparisonView: View {
    @EnvironmentObject private var preferences: PreferencesService
    @EnvironmentObject private var liveProcessStore: LiveProcessWhatIfStore

    @StateObject private var viewModel = ComparisonViewModel()
    @State private var showingScenarios = false
    @State private var showingLiveProcessPicker = false

    var body: some View {
        VStack(spacing: 0) {
            comparisonToolbar

            Divider()

            if viewModel.results.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        if let captureTime = liveSnapshotCaptureTime {
                            LiveSnapshotComparisonBaselineCard(
                                captureTime: captureTime,
                                processes: liveProcessStore.all,
                                selectedCount: viewModel.processes.count
                            )
                            .padding(.horizontal, 24)
                        }

                        learningTakeawayCard
                            .padding(.horizontal, 24)

                        metricsComparisonCharts
                            .padding(.horizontal, 24)

                        sideBySideGantt
                            .padding(.horizontal, 24)

                        comparisonTable
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }
                    .padding(.top, 18)
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingScenarios) {
            ComparisonScenarioSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingLiveProcessPicker) {
            LiveProcessPickerSheet()
                .environmentObject(liveProcessStore)
        }
    }

    // MARK: - Toolbar
    private var comparisonToolbar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Label("Algorithm Comparison", systemImage: "chart.bar.xaxis")
                    .font(.headline)

                Spacer()

                if viewModel.selectedAlgorithms.contains("rr") {
                    HStack(spacing: 6) {
                        Text("Quantum")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Stepper("\(viewModel.timeQuantum)", value: $viewModel.timeQuantum, in: 1...20)
                            .labelsHidden()
                        Text("\(viewModel.timeQuantum)")
                            .font(.system(.caption, design: .monospaced).weight(.semibold))
                            .frame(width: 22)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                Text("\(viewModel.processes.count) proc")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.quaternary.opacity(0.8))
                    .clipShape(Capsule())

                sourceBadge

                Menu {
                    Button(action: { showingScenarios = true }) {
                        Label("Load Scenario", systemImage: "folder")
                    }
                    Button(action: { viewModel.generateRandomProcesses() }) {
                        Label("Generate Random", systemImage: "dice")
                    }
                } label: {
                    Label("Processes", systemImage: "square.and.arrow.down")
                }
                .menuStyle(.borderlessButton)

                Button(action: { viewModel.runComparison() }) {
                    Label("Compare", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.processes.isEmpty || viewModel.selectedAlgorithms.isEmpty)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AlgorithmInfo.all) { algo in
                        Toggle(isOn: Binding(
                            get: { viewModel.selectedAlgorithms.contains(algo.id) },
                            set: { _ in viewModel.toggleAlgorithm(algo) }
                        )) {
                            HStack(spacing: 6) {
                                Image(systemName: algo.icon)
                                    .font(.caption)
                                Text(algo.shortName)
                                    .font(.caption.weight(.semibold))
                            }
                        }
                        .toggleStyle(.button)
                        .buttonStyle(.bordered)
                        .tint(algo.color)
                        .controlSize(.small)
                        .help(algo.description)
                    }
                }
            }

            liveSnapshotControls
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private var liveSnapshotControls: some View {
        HStack(spacing: 8) {
            Label("Live Snapshot", systemImage: "waveform.path.ecg")
                .font(.caption.weight(.semibold))

            if let snapshot = liveProcessStore.lastSnapshot {
                Text("Seen \(snapshot.totalProcessesSeen)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("Selected \(snapshot.selectedCount)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if liveProcessStore.autoRefreshEnabled {
                Text("Auto \(Int(liveProcessStore.refreshIntervalSeconds))s")
                    .font(.caption2)
                    .foregroundStyle(.green)
            } else {
                Text("Manual refresh")
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            if let snapshot = liveProcessStore.lastSnapshot {
                Text(snapshotFreshnessText(snapshot.capturedAt))
                    .font(.caption2)
                    .foregroundStyle(snapshotIsStale(snapshot.capturedAt) ? .orange : .secondary)
            }

            Spacer()

            Button {
                liveProcessStore.refreshNow()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Button {
                showingLiveProcessPicker = true
            } label: {
                Label("Select", systemImage: "checklist")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Toggle("Auto", isOn: Binding(
                get: { liveProcessStore.autoRefreshEnabled },
                set: { newValue in
                    liveProcessStore.autoRefreshEnabled = newValue
                    preferences.liveWhatIfAutoRefreshEnabled = newValue
                }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)

            Menu {
                ForEach([2.0, 5.0, 10.0], id: \.self) { interval in
                    Button {
                        liveProcessStore.refreshIntervalSeconds = interval
                        preferences.liveWhatIfRefreshIntervalSeconds = interval
                    } label: {
                        if liveProcessStore.refreshIntervalSeconds == interval {
                            Label("\(Int(interval))s", systemImage: "checkmark")
                        } else {
                            Text("\(Int(interval))s")
                        }
                    }
                }
            } label: {
                Label("Interval \(Int(liveProcessStore.refreshIntervalSeconds))s", systemImage: "timer")
            }
            .menuStyle(.borderlessButton)
            .controlSize(.small)
            .disabled(!liveProcessStore.autoRefreshEnabled)

            Button {
                compareLiveSnapshot()
            } label: {
                Label("Compare Live Snapshot", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(liveProcessStore.all.filter(\.isSelected).isEmpty || viewModel.selectedAlgorithms.isEmpty)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 8) {
                Text("Compare Tradeoffs")
                    .font(.title2.weight(.bold))

                Text("Pick algorithms, load a workload, and learn how fairness, latency, and utilization change.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 480)
            }

            HStack(spacing: 10) {
                Button("Load Scenario") { showingScenarios = true }
                    .buttonStyle(.bordered)

                Button("Random Processes") { viewModel.generateRandomProcesses() }
                    .buttonStyle(.borderedProminent)
            }

            if !viewModel.processes.isEmpty {
                Text("Ready with \(viewModel.processes.count) processes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let captureTime = liveSnapshotCaptureTime {
                LiveSnapshotComparisonBaselineCard(
                    captureTime: captureTime,
                    processes: liveProcessStore.all,
                    selectedCount: viewModel.processes.count
                )
                .frame(maxWidth: 720)
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var learningTakeawayCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Learning Takeaway", systemImage: "lightbulb")
                    .font(.headline)
                Spacer()
            }

            Text(takeawayText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if let bestWait = viewModel.results.min(by: { $0.metrics.averageWaitingTime < $1.metrics.averageWaitingTime }) {
                    metricBadge(title: "Best Wait", value: bestWait.algorithm.shortName, color: .orange)
                }
                if let bestResponse = viewModel.results.min(by: { $0.metrics.averageResponseTime < $1.metrics.averageResponseTime }) {
                    metricBadge(title: "Best Response", value: bestResponse.algorithm.shortName, color: .green)
                }
                if let bestUtil = viewModel.results.max(by: { $0.metrics.cpuUtilization < $1.metrics.cpuUtilization }) {
                    metricBadge(title: "Best Util", value: bestUtil.algorithm.shortName, color: .blue)
                }
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var takeawayText: String {
        guard !viewModel.results.isEmpty else { return "" }

        let waitBest = viewModel.results.min(by: { $0.metrics.averageWaitingTime < $1.metrics.averageWaitingTime })
        let utilBest = viewModel.results.max(by: { $0.metrics.cpuUtilization < $1.metrics.cpuUtilization })

        if waitBest?.algorithm.id == utilBest?.algorithm.id, let winner = waitBest?.algorithm.shortName {
            return "For this workload, \(winner) currently balances queue latency and CPU usage best."
        }

        return "No universal winner here: one algorithm reduces waiting while another maximizes utilization. Pick based on system goals."
    }

    private func metricBadge(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var liveSnapshotCaptureTime: Date? {
        guard case let .liveSnapshot(captureTime) = viewModel.inputSource else {
            return nil
        }
        return captureTime
    }

    private func compareLiveSnapshot() {
        let mapped = liveProcessStore.selectedAsSchedulerProcesses()
        guard !mapped.isEmpty else {
            return
        }

        let capturedAt = liveProcessStore.lastSnapshot?.capturedAt ?? Date()
        viewModel.loadLiveSnapshot(processes: mapped, captureTime: capturedAt)
        viewModel.runComparison()
    }

    @ViewBuilder
    private var sourceBadge: some View {
        switch viewModel.inputSource {
        case .manual:
            Label("Manual", systemImage: "keyboard")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.quaternary.opacity(0.8))
                .clipShape(Capsule())
        case let .scenario(name):
            Label(name, systemImage: "folder")
                .font(.caption)
                .foregroundStyle(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.12))
                .clipShape(Capsule())
                .help("Loaded scenario source")
        case let .liveSnapshot(captureTime):
            HStack(spacing: 4) {
                Image(systemName: "waveform.path.ecg")
                Text(captureTime, format: Date.FormatStyle(date: .omitted, time: .shortened))
            }
            .font(.caption)
            .foregroundStyle(.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
            .help("Live snapshot source")
        }
    }

    private func snapshotFreshnessText(_ captureTime: Date) -> String {
        let seconds = max(0, Int(Date().timeIntervalSince(captureTime)))
        if seconds < 60 {
            return "· \(seconds)s ago"
        }
        return "· \(seconds / 60)m ago"
    }

    private func snapshotIsStale(_ captureTime: Date) -> Bool {
        let age = Date().timeIntervalSince(captureTime)
        let staleThreshold = max(10.0, liveProcessStore.refreshIntervalSeconds * 2.0)
        return age > staleThreshold
    }

    // MARK: - Metrics Comparison Charts
    private var metricsComparisonCharts: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Performance Metrics")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14),
            ], spacing: 14) {
                comparisonBarChart(
                    title: "Avg Turnaround",
                    keyPath: \.averageTurnaroundTime,
                    unit: "units",
                    lowerIsBetter: true
                )

                comparisonBarChart(
                    title: "Avg Waiting",
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
        VStack(alignment: .leading, spacing: 8) {
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
            .frame(height: 156)

            if let best = bestResult(keyPath: keyPath, lowerIsBetter: lowerIsBetter) {
                Text("Best: \(best.algorithm.shortName)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(best.algorithm.color)
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func bestResult(keyPath: KeyPath<PerformanceMetrics, Double>, lowerIsBetter: Bool) -> SchedulingResult? {
        if lowerIsBetter {
            return viewModel.results.min { $0.metrics[keyPath: keyPath] < $1.metrics[keyPath: keyPath] }
        }
        return viewModel.results.max { $0.metrics[keyPath: keyPath] < $1.metrics[keyPath: keyPath] }
    }

    // MARK: - Side-by-Side Gantt
    private var sideBySideGantt: some View {
        VStack(alignment: .leading, spacing: 14) {
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

                        Text("Total: \(result.metrics.totalTime)")
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
                    .chartXAxisLabel("Time")
                    .frame(height: CGFloat(Set(result.timeline.map(\.processName)).count) * 30 + 26)
                }
                .padding(14)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    // MARK: - Comparison Table
    private var comparisonTable: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary Table")
                .font(.headline)

            VStack(spacing: 1) {
                HStack(spacing: 0) {
                    Text("Algorithm").frame(width: 130, alignment: .leading)
                    Text("Avg TAT").frame(width: 80)
                    Text("Avg Wait").frame(width: 80)
                    Text("Avg Resp").frame(width: 80)
                    Text("CPU %").frame(width: 70)
                    Text("Switches").frame(width: 80)
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

                        Text(String(format: "%.2f", result.metrics.averageTurnaroundTime)).frame(width: 80)
                        Text(String(format: "%.2f", result.metrics.averageWaitingTime)).frame(width: 80)
                        Text(String(format: "%.2f", result.metrics.averageResponseTime)).frame(width: 80)
                        Text(String(format: "%.1f%%", result.metrics.cpuUtilization)).frame(width: 70)
                        Text("\(result.metrics.contextSwitches)").frame(width: 80)
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

private struct LiveSnapshotComparisonBaselineCard: View {
    let captureTime: Date
    let processes: [LiveProcessCandidate]
    let selectedCount: Int

    var body: some View {
        let aggregateCPU = min(100.0, processes.reduce(0.0) { $0 + $1.cpuUsage })
        let aggregateMemoryGB = processes.reduce(0.0) { $0 + $1.memoryMB } / 1024.0
        let selectedCPU = processes.filter(\.isSelected).reduce(0.0) { $0 + $1.cpuUsage }

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Current System Baseline", systemImage: "gauge.with.dots.needle.67percent")
                    .font(.headline)
                Spacer()
                Text(captureTime, format: Date.FormatStyle(date: .omitted, time: .standard))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                baselineStat(title: "Processes", value: "\(processes.count)", color: .blue)
                baselineStat(title: "Selected", value: "\(selectedCount)", color: .green)
                baselineStat(title: "CPU Sample", value: String(format: "%.1f%%", aggregateCPU), color: .orange)
                baselineStat(title: "Resident Mem", value: String(format: "%.1f GB", aggregateMemoryGB), color: .purple)
                baselineStat(title: "Selected CPU", value: String(format: "%.1f%%", selectedCPU), color: .red)
            }

            HStack(spacing: 8) {
                ComparisonHintBadge(
                    title: "Selection Why",
                    text: "Top active processes are prefilled by CPU and memory to approximate meaningful scheduling contention."
                )
                ComparisonHintBadge(
                    title: "Burst Modeling",
                    text: "Higher CPU and thread counts create larger burst estimates, so compute-heavy tasks occupy more timeline space."
                )
                ComparisonHintBadge(
                    title: "Arrival Modeling",
                    text: "Older processes (earlier start time) are assigned earlier arrivals. That changes FCFS/SJF ordering substantially."
                )
                ComparisonHintBadge(
                    title: "Algorithm Impact",
                    text: "FCFS rewards old arrivals, RR favors response fairness, and SRTF/Priority can preempt aggressively when modeled burst/priority differs."
                )
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func baselineStat(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(color)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ComparisonHintBadge: View {
    let title: String
    let text: String

    @State private var showingPopover = false

    var body: some View {
        Button {
            showingPopover = true
        } label: {
            Label(title, systemImage: "questionmark.circle")
                .font(.caption.weight(.semibold))
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .popover(isPresented: $showingPopover, arrowEdge: .top) {
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 260, alignment: .leading)
                .padding(12)
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
                        viewModel.loadScenario(scenario.processes, name: scenario.name)
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
