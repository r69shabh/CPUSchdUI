import SwiftUI

// MARK: - Simulator View
struct SimulatorView: View {
    @StateObject private var viewModel = SimulatorViewModel()
    @State private var showingProcessSheet = false
    @State private var showingScenarios = false

    var body: some View {
        VStack(spacing: 0) {
            // Top Toolbar
            simulatorToolbar

            Divider()

            // Main Content
            HSplitView {
                // Left Panel: Process Input
                processInputPanel
                    .frame(minWidth: 280, idealWidth: 340, maxWidth: 420)

                // Right Panel: Visualization & Results
                resultsPanel
                    .frame(minWidth: 500)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showingProcessSheet) {
            AddProcessSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingScenarios) {
            ScenarioPickerSheet(viewModel: viewModel)
        }
    }

    // MARK: - Toolbar
    private var simulatorToolbar: some View {
        HStack(spacing: 16) {
            // Algorithm Picker
            Menu {
                ForEach(AlgorithmInfo.all) { algo in
                    Button(action: {
                        withAnimation { viewModel.selectedAlgorithm = algo }
                    }) {
                        Label(algo.name, systemImage: algo.icon)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.selectedAlgorithm.icon)
                        .foregroundStyle(viewModel.selectedAlgorithm.color.gradient)
                        .symbolRenderingMode(.hierarchical)
                    Text(viewModel.selectedAlgorithm.shortName)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(viewModel.selectedAlgorithm.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)

            // Time Quantum (for Round Robin)
            if viewModel.selectedAlgorithm.needsQuantum {
                HStack(spacing: 8) {
                    Text("Quantum:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Button(action: { if viewModel.timeQuantum > 1 { viewModel.timeQuantum -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)

                        Text("\(viewModel.timeQuantum)")
                            .font(.system(.body, design: .monospaced).bold())
                            .frame(width: 28)

                        Button(action: { if viewModel.timeQuantum < 20 { viewModel.timeQuantum += 1 } }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .transition(.scale.combined(with: .opacity))
            }

            // Algorithm info badge
            HStack(spacing: 4) {
                Image(systemName: viewModel.selectedAlgorithm.isPreemptive ? "arrow.triangle.swap" : "arrow.right")
                    .font(.caption2)
                Text(viewModel.selectedAlgorithm.isPreemptive ? "Preemptive" : "Non-Preemptive")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())

            Spacer()

            // Action Buttons
            if viewModel.isRunning {
                LoadingSpinner()
            }

            HStack(spacing: 10) {
                Button(action: { viewModel.clearAll() }) {
                    Label("Clear", systemImage: "trash")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.processes.isEmpty)

                Button(action: { viewModel.runSimulation() }) {
                    Label("Run", systemImage: "play.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(viewModel.processes.isEmpty || viewModel.isRunning)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedAlgorithm.needsQuantum)
    }

    // MARK: - Process Input Panel
    private var processInputPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
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
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            // Process count & summary
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
                .background(Color.secondary.opacity(0.15))
            }

            // Process List
            if viewModel.processes.isEmpty {
                emptyProcessState
            } else {
                processTable
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var emptyProcessState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondary.opacity(0.5))

            VStack(spacing: 6) {
                Text("No Processes")
                    .font(.title3.bold())

                Text("Click + to add processes\nor load a scenario")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 8) {
                Button("Add Process") { showingProcessSheet = true }
                    .buttonStyle(.bordered)

                Button("Random") { viewModel.generateRandomProcesses() }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
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
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
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
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.blue.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 50))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 8) {
                Text("Ready to Visualize")
                    .font(.title.bold())

                Text("Add processes and click Run to see the scheduling visualization")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }

            // Quick start guide
            VStack(alignment: .leading, spacing: 14) {
                QuickStartStep(number: 1, text: "Add processes using the + button", icon: "plus.circle.fill")
                QuickStartStep(number: 2, text: "Select a scheduling algorithm", icon: "cpu")
                QuickStartStep(number: 3, text: "Click Run to visualize", icon: "play.fill")
            }
            .padding(20)
            .background(.blue.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.blue.opacity(0.12), lineWidth: 1)
            }

            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Process Row Component
struct ProcessRow: View {
    let process: SchedulerProcess
    let onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(process.color.gradient)
                .frame(width: 5, height: 40)

            // Process info
            VStack(alignment: .leading, spacing: 4) {
                Text(process.name)
                    .font(.system(.subheadline, design: .rounded).bold())

                HStack(spacing: 10) {
                    InfoBadge(icon: "clock", text: "Arrival: \(process.arrivalTime)")
                    InfoBadge(icon: "speedometer", text: "Burst: \(process.burstTime)")
                    InfoBadge(icon: "star.fill", text: "Pri: \(process.priority)")
                }
            }

            Spacer()

            // Delete button
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
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.15))
                    .frame(width: 30, height: 30)

                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
            }

            Text(text)
                .font(.subheadline)
        }
    }
}
