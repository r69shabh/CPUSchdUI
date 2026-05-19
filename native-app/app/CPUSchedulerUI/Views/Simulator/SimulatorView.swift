import SwiftUI

// MARK: - Simulator View
struct SimulatorView: View {
    @EnvironmentObject private var preferences: PreferencesService
    @EnvironmentObject private var liveProcessStore: LiveProcessWhatIfStore

    @StateObject private var viewModel = SimulatorViewModel()
    @State private var showingProcessSheet = false
    @State private var showingScenarios = false
    @State private var showingLiveProcessPicker = false
    @State private var showingRunExplanation = false
    @State private var selectedTerm: LearningTerm?

    var body: some View {
        VStack(spacing: 0) {
            simulatorToolbar

            Divider()

            HSplitView {
                processInputPanel
                    .frame(minWidth: 300, idealWidth: 360, maxWidth: 440)

                resultsPanel
                    .frame(minWidth: 560)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingProcessSheet) {
            AddProcessSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingScenarios) {
            ScenarioPickerSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingLiveProcessPicker) {
            LiveProcessPickerSheet()
                .environmentObject(liveProcessStore)
        }
    }

    // MARK: - Toolbar
    private var simulatorToolbar: some View {
        HStack(spacing: 12) {
            Picker("Algorithm", selection: $viewModel.selectedAlgorithm) {
                ForEach(AlgorithmInfo.all) { algo in
                    Label(algo.name, systemImage: algo.icon)
                        .tag(algo)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 280)

            if viewModel.selectedAlgorithm.needsQuantum {
                HStack(spacing: 8) {
                    Text("Quantum")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Stepper("\(viewModel.timeQuantum)", value: $viewModel.timeQuantum, in: 1...20)
                        .labelsHidden()

                    Text("\(viewModel.timeQuantum)")
                        .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                        .frame(width: 28)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .transition(.opacity.combined(with: .scale))
            }

            Label(
                viewModel.selectedAlgorithm.isPreemptive ? "Preemptive" : "Non-preemptive",
                systemImage: viewModel.selectedAlgorithm.isPreemptive ? "arrow.triangle.swap" : "arrow.right"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary.opacity(0.8))
            .clipShape(Capsule())

            sourceBadge

            if preferences.showTooltips {
                glossaryInlineStrip
            }

            Spacer()

            Button {
                showingRunExplanation = true
            } label: {
                Label("Explain", systemImage: "questionmark.circle")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showingRunExplanation, arrowEdge: .top) {
                RunExplanationPopover(
                    algorithm: viewModel.selectedAlgorithm,
                    result: viewModel.currentResult,
                    processCount: viewModel.processes.count,
                    quantum: viewModel.timeQuantum
                )
                .frame(width: 380)
                .padding(16)
            }

            if viewModel.isRunning {
                LoadingSpinner()
                    .help("Scheduling in progress")
            }

            Button(action: { viewModel.clearAll() }) {
                Label("Clear", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.processes.isEmpty)

            Button(action: { viewModel.runSimulation() }) {
                Label("Run", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.processes.isEmpty || viewModel.isRunning)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.bar)
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedAlgorithm.needsQuantum)
    }

    private var glossaryInlineStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(LearningTerm.allCases) { term in
                    Button {
                        selectedTerm = term
                    } label: {
                        Text(term.shortLabel)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(term.color.opacity(0.15))
                            .foregroundStyle(term.color)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help(term.explanation)
                }
            }
        }
        .frame(maxWidth: 250)
        .popover(item: $selectedTerm, attachmentAnchor: .point(.bottom), arrowEdge: .top) { selected in
            TermPopover(term: selected)
                .frame(width: 280)
                .padding(14)
        }
    }

    // MARK: - Process Input Panel
    private var processInputPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("Processes", systemImage: "list.bullet.rectangle.portrait")
                    .font(.headline)

                Spacer()

                Menu {
                    Button(action: { showingProcessSheet = true }) {
                        Label("Add Manually", systemImage: "plus.circle")
                    }

                    Divider()

                    Button(action: { showingScenarios = true }) {
                        Label("Load Scenario", systemImage: "folder")
                    }

                    Button(action: { viewModel.generateRandomProcesses() }) {
                        Label("Generate Random", systemImage: "dice")
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
                .menuStyle(.borderlessButton)
                .controlSize(.large)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            liveSnapshotControls
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

            Divider()

            if !viewModel.processes.isEmpty {
                HStack {
                    Text("\(viewModel.processes.count) process\(viewModel.processes.count == 1 ? "" : "es")")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("Total burst: \(viewModel.processes.reduce(0) { $0 + $1.burstTime })")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.12))
            }

            if viewModel.processes.isEmpty {
                emptyProcessState
            } else {
                processTable
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var liveSnapshotControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Label("Live Snapshot", systemImage: "waveform.path.ecg")
                    .font(.subheadline.weight(.semibold))

                if liveProcessStore.autoRefreshEnabled {
                    Label("\(Int(liveProcessStore.refreshIntervalSeconds))s auto", systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(.green)
                } else {
                    Text("Manual refresh")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let snapshot = liveProcessStore.lastSnapshot {
                    Text(snapshot.capturedAt, format: Date.FormatStyle(date: .omitted, time: .standard))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Text(snapshotFreshnessText(snapshot.capturedAt))
                        .font(.caption2)
                        .foregroundStyle(snapshotIsStale(snapshot.capturedAt) ? .orange : .secondary)
                }
            }

            HStack(spacing: 8) {
                Button {
                    liveProcessStore.refreshNow()
                } label: {
                    Label("Refresh Snapshot", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                Button {
                    showingLiveProcessPicker = true
                } label: {
                    Label("Select Processes", systemImage: "checklist")
                }
                .buttonStyle(.bordered)

                Button {
                    loadLiveSnapshotIntoSimulator()
                } label: {
                    Label("Load Into Simulator", systemImage: "tray.and.arrow.down.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(liveProcessStore.all.filter(\.isSelected).isEmpty)
            }

            HStack(spacing: 8) {
                if let snapshot = liveProcessStore.lastSnapshot {
                    Text("Seen: \(snapshot.totalProcessesSeen)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Selected: \(snapshot.selectedCount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No snapshot captured yet")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("Auto", isOn: Binding(
                    get: { liveProcessStore.autoRefreshEnabled },
                    set: { newValue in
                        liveProcessStore.autoRefreshEnabled = newValue
                        preferences.liveWhatIfAutoRefreshEnabled = newValue
                    }
                ))
                .toggleStyle(.switch)
                .controlSize(.small)
                .help("Enable periodic snapshot refresh.")

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
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var emptyProcessState: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundStyle(Color.secondary.opacity(0.5))

            VStack(spacing: 6) {
                Text("No Processes")
                    .font(.title3.weight(.semibold))

                Text("Add processes or load a scenario to begin.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button("Add Process") { showingProcessSheet = true }
                    .buttonStyle(.bordered)

                Button("Random") { viewModel.generateRandomProcesses() }
                    .buttonStyle(.borderedProminent)
            }
            .controlSize(.small)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var processTable: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(viewModel.processes) { process in
                    ProcessRow(process: process, onDelete: {
                        viewModel.removeProcess(process)
                    })
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Results Panel
    @ViewBuilder
    private var resultsPanel: some View {
        if let result = viewModel.currentResult {
            ScrollView {
                VStack(spacing: 0) {
                    if let captureTime = liveSnapshotCaptureTime {
                        LiveSnapshotBaselinePanel(
                            captureTime: captureTime,
                            totalProcessesSeen: liveProcessStore.lastSnapshot?.totalProcessesSeen ?? liveProcessStore.all.count,
                            selectedCount: viewModel.processes.count,
                            topCPU: Array(liveProcessStore.all.prefix(4))
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                    }

                    if preferences.showLearningCoach {
                        LearningCoachPanel(result: result)
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                    }

                    GanttChartSection(result: result)

                    Divider()
                        .padding(.horizontal)

                    MetricsSection(metrics: result.metrics)
                }
            }
            .transition(.opacity.combined(with: .move(edge: .trailing)))
        } else {
            emptyResultsState
        }
    }

    private var emptyResultsState: some View {
        VStack(spacing: 24) {
            Spacer()

            if let captureTime = liveSnapshotCaptureTime {
                LiveSnapshotBaselinePanel(
                    captureTime: captureTime,
                    totalProcessesSeen: liveProcessStore.lastSnapshot?.totalProcessesSeen ?? liveProcessStore.all.count,
                    selectedCount: viewModel.processes.count,
                    topCPU: Array(liveProcessStore.all.prefix(4))
                )
                .frame(maxWidth: 760)
            }

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.09))
                    .frame(width: 112, height: 112)

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 46))
                    .foregroundStyle(Color.accentColor)
            }

            VStack(spacing: 8) {
                Text("Ready to Simulate")
                    .font(.title2.weight(.bold))

                Text("Run an algorithm, then inspect the timeline and hover chips for guided explanations.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 440)
            }

            VStack(alignment: .leading, spacing: 12) {
                QuickStartStep(number: 1, text: "Add processes using + or load a scenario", icon: "plus.circle.fill")
                QuickStartStep(number: 2, text: "Pick an algorithm and set quantum if needed", icon: "cpu")
                QuickStartStep(number: 3, text: "Run and inspect tooltips/popovers for live learning", icon: "questionmark.bubble")
            }
            .padding(18)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Spacer()
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var liveSnapshotCaptureTime: Date? {
        guard case let .liveSnapshot(captureTime) = viewModel.inputSource else {
            return nil
        }
        return captureTime
    }

    private func loadLiveSnapshotIntoSimulator() {
        let mapped = liveProcessStore.selectedAsSchedulerProcesses()
        guard !mapped.isEmpty else {
            return
        }
        let capturedAt = liveProcessStore.lastSnapshot?.capturedAt ?? Date()
        viewModel.loadLiveSnapshot(processes: mapped, captureTime: capturedAt)
    }

    @ViewBuilder
    private var sourceBadge: some View {
        switch viewModel.inputSource {
        case .manual:
            Label("Manual", systemImage: "keyboard")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.quaternary.opacity(0.8))
                .clipShape(Capsule())
        case let .scenario(name):
            Label(name, systemImage: "folder")
                .font(.caption)
                .foregroundStyle(.blue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
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
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
            .help("Live snapshot capture time")
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
}

private enum LearningTerm: String, CaseIterable, Identifiable {
    case turnaround
    case waiting
    case response
    case contextSwitch
    case throughput

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .turnaround: return "TAT"
        case .waiting: return "Wait"
        case .response: return "Response"
        case .contextSwitch: return "Switch"
        case .throughput: return "Throughput"
        }
    }

    var title: String {
        switch self {
        case .turnaround: return "Turnaround Time"
        case .waiting: return "Waiting Time"
        case .response: return "Response Time"
        case .contextSwitch: return "Context Switch"
        case .throughput: return "Throughput"
        }
    }

    var explanation: String {
        switch self {
        case .turnaround:
            return "Total time from process arrival to completion."
        case .waiting:
            return "Time spent waiting in the ready queue."
        case .response:
            return "Delay from arrival until first CPU allocation."
        case .contextSwitch:
            return "CPU switching from one process to another."
        case .throughput:
            return "How many processes finish per unit time."
        }
    }

    var color: Color {
        switch self {
        case .turnaround: return .blue
        case .waiting: return .orange
        case .response: return .green
        case .contextSwitch: return .purple
        case .throughput: return .pink
        }
    }
}

private struct TermPopover: View {
    let term: LearningTerm

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(term.title)
                .font(.headline)
            Text(term.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct RunExplanationPopover: View {
    let algorithm: AlgorithmInfo
    let result: SchedulingResult?
    let processCount: Int
    let quantum: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: algorithm.icon)
                    .foregroundStyle(algorithm.color)
                Text(algorithm.name)
                    .font(.headline)
            }

            Text(algorithm.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Text("Current setup")
                .font(.subheadline.weight(.semibold))
            Text("• Processes: \(processCount)")
            Text("• Mode: \(algorithm.isPreemptive ? "Preemptive" : "Non-preemptive")")
            if algorithm.needsQuantum {
                Text("• Quantum: \(quantum)")
            }

            if let result {
                Divider()
                Text("Latest run insight")
                    .font(.subheadline.weight(.semibold))
                Text(runInsight(result.metrics))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption)
    }

    private func runInsight(_ metrics: PerformanceMetrics) -> String {
        if metrics.contextSwitches > max(3, metrics.totalTime / 2) {
            return "High switch count suggests frequent preemption. Great responsiveness, but extra overhead."
        }
        if metrics.averageWaitingTime < metrics.averageTurnaroundTime / 3 {
            return "Low waiting relative to turnaround suggests queueing is efficient for this workload."
        }
        return "Use Comparison to check whether another algorithm can reduce waiting while preserving throughput."
    }
}

private struct LiveSnapshotBaselinePanel: View {
    let captureTime: Date
    let totalProcessesSeen: Int
    let selectedCount: Int
    let topCPU: [LiveProcessCandidate]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Current System View Baseline", systemImage: "waveform.path.ecg")
                    .font(.headline)
                Spacer()
                Text(captureTime, format: Date.FormatStyle(date: .omitted, time: .standard))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                statPill(title: "Seen", value: "\(totalProcessesSeen)", color: .blue)
                statPill(title: "Selected", value: "\(selectedCount)", color: .green)
                Text("This is a snapshot baseline, not the kernel's real scheduler timeline.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                LiveHintBadge(
                    title: "Selection",
                    text: "Top 12 is prefilled by CPU desc, then memory desc, then PID. You can edit it."
                )
                LiveHintBadge(
                    title: "Arrival",
                    text: "Arrival is derived from start-time order: older processes arrive earlier (rank capped at 20)."
                )
                LiveHintBadge(
                    title: "Burst",
                    text: "Burst = clamp(ceil(CPU/4) + min(threads,8)/2, 1...25). This models relative compute intensity."
                )
                LiveHintBadge(
                    title: "Priority",
                    text: "Priority maps nice [-20,20] to scheduler [1,10], where lower number is higher priority."
                )
            }

            if !topCPU.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(topCPU, id: \.pid) { process in
                            Label("\(process.name) \(String(format: "%.1f%%", process.cpuUsage))", systemImage: "flame.fill")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Capsule())
                                .help("Top CPU process in current snapshot")
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func statPill(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(color)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

private struct LiveHintBadge: View {
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

private struct LearningCoachPanel: View {
    enum Focus: String, CaseIterable, Identifiable {
        case timeline = "Timeline"
        case fairness = "Fairness"
        case efficiency = "Efficiency"

        var id: String { rawValue }
    }

    let result: SchedulingResult
    @State private var focus: Focus = .timeline

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Live Learning Coach", systemImage: "graduationcap")
                    .font(.headline)
                Spacer()
                Picker("Focus", selection: $focus) {
                    ForEach(Focus.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
            }

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                statPill(title: "Switches", value: "\(result.metrics.contextSwitches)", color: .purple)
                statPill(title: "Wait", value: String(format: "%.2f", result.metrics.averageWaitingTime), color: .orange)
                statPill(title: "Throughput", value: String(format: "%.3f", result.metrics.throughput), color: .blue)
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var message: String {
        switch focus {
        case .timeline:
            if result.metrics.contextSwitches == 0 {
                return "The CPU ran mostly in long uninterrupted slices. This usually means low scheduling overhead."
            }
            return "Each segment in the timeline shows when the scheduler picked a process. Hover chips below to inspect each decision."
        case .fairness:
            if result.metrics.averageResponseTime <= result.metrics.averageWaitingTime {
                return "Response time is competitive, so processes generally start execution quickly."
            }
            return "Some processes wait longer before first CPU access. Consider RR or preemptive options for better fairness."
        case .efficiency:
            if result.metrics.cpuUtilization > 90 {
                return "High CPU utilization indicates minimal idle gaps for this workload."
            }
            return "Lower utilization may indicate arrival gaps or idle windows in the schedule."
        }
    }

    private func statPill(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Process Row Component
struct ProcessRow: View {
    let process: SchedulerProcess
    let onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(process.color.gradient)
                .frame(width: 5, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(process.name)
                    .font(.system(.subheadline, design: .rounded).bold())

                HStack(spacing: 10) {
                    InfoBadge(icon: "clock", text: "Arrival: \(process.arrivalTime)")
                        .help("Time at which this process enters the ready queue")
                    InfoBadge(icon: "speedometer", text: "Burst: \(process.burstTime)")
                        .help("CPU time this process requires")
                    InfoBadge(icon: "star.fill", text: "Pri: \(process.priority)")
                        .help("Lower number means higher priority in priority schedulers")
                }
            }

            Spacer()

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isHovered ? Color(nsColor: .controlBackgroundColor) : Color(nsColor: .controlBackgroundColor).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(isHovered ? process.color.opacity(0.3) : .clear, lineWidth: 1)
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(process.name), arrival \(process.arrivalTime), burst \(process.burstTime), priority \(process.priority)")
    }
}

// MARK: - Quick Start Step
struct QuickStartStep: View {
    let number: Int
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentColor)
            }

            Text(text)
                .font(.subheadline)
        }
    }
}
