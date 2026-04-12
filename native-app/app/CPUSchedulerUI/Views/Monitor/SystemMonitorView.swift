import SwiftUI
import Charts

// MARK: - System Monitor View
struct SystemMonitorView: View {
    @StateObject private var viewModel = MonitorViewModel()
    @State private var showingInsights = false
    @State private var hoveredPID: Int?

    var body: some View {
        VStack(spacing: 0) {
            monitorToolbar

            Divider()

            ScrollView {
                VStack(spacing: 18) {
                    overviewCards
                        .padding(.horizontal, 24)

                    cpuHistoryChart
                        .padding(.horizontal, 24)

                    processListSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
                .padding(.top, 18)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { viewModel.startMonitoring() }
        .onDisappear { viewModel.stopMonitoring() }
    }

    // MARK: - Toolbar
    private var monitorToolbar: some View {
        HStack(spacing: 14) {
            Label("System Monitor", systemImage: "waveform.path.ecg")
                .font(.headline)

            PulseDot(color: .green)
            Text("Live")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.green)

            Spacer()

            Picker("Sort by", selection: $viewModel.sortOrder) {
                ForEach(MonitorViewModel.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 320)

            Button {
                showingInsights = true
            } label: {
                Label("Explain", systemImage: "questionmark.circle")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showingInsights, arrowEdge: .top) {
                MonitorInsightPopover(totalCPU: viewModel.totalCPU, processCount: viewModel.processes.count)
                    .frame(width: 350)
                    .padding(16)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.bar)
    }

    // MARK: - Overview Cards
    private var overviewCards: some View {
        HStack(spacing: 14) {
            overviewCard(
                title: "CPU Usage",
                icon: "cpu",
                color: .blue,
                value: String(format: "%.1f%%", viewModel.cpuHistory.last ?? 0),
                subtitle: "Aggregate active CPU"
            ) {
                Chart(Array(viewModel.cpuHistory.suffix(20).enumerated()), id: \.offset) { index, value in
                    LineMark(x: .value("Time", index), y: .value("CPU", value))
                        .foregroundStyle(.blue.gradient)
                        .interpolationMethod(.catmullRom)
                    AreaMark(x: .value("Time", index), y: .value("CPU", value))
                        .foregroundStyle(.blue.opacity(0.1).gradient)
                        .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: 0...100)
                .frame(height: 44)
            }

            overviewCard(
                title: "Memory Pressure",
                icon: "memorychip",
                color: .purple,
                value: String(format: "%.1f%%", viewModel.memoryUsage),
                subtitle: "Estimated resident memory"
            ) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.18))
                        Capsule()
                            .fill(.purple.gradient)
                            .frame(width: geo.size.width * viewModel.memoryUsage / 100)
                    }
                }
                .frame(height: 7)
            }

            overviewCard(
                title: "Process Count",
                icon: "square.stack.3d.up",
                color: .orange,
                value: "\(viewModel.processes.count)",
                subtitle: "Running + sleeping processes"
            ) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Running: \(viewModel.processes.filter { $0.state == "Running" }.count)")
                    Text("Sleeping: \(viewModel.processes.filter { $0.state == "Sleeping" }.count)")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func overviewCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        value: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            content()
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - CPU History Chart
    private var cpuHistoryChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("CPU History")
                    .font(.headline)
                Spacer()
                Text("Hover to inspect trend")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Chart(Array(viewModel.cpuHistory.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Time", index),
                    y: .value("CPU %", value)
                )
                .foregroundStyle(.blue.gradient)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Time", index),
                    y: .value("CPU %", value)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue.opacity(0.22), .blue.opacity(0.03)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 0...100)
            .chartYAxisLabel("%")
            .chartXAxisLabel("Recent samples")
            .frame(height: 190)
            .chartPlotStyle { plot in
                plot
                    .background(Color.secondary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Process List
    private var processListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Processes")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.sortedProcesses.count) rows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 0) {
                Text("PID").frame(width: 70, alignment: .leading)
                Text("Name").frame(width: 170, alignment: .leading)
                Text("CPU %").frame(width: 90)
                Text("Memory").frame(width: 110)
                Text("Threads").frame(width: 80)
                Text("User").frame(width: 100, alignment: .leading)
                Text("State").frame(width: 100)
            }
            .font(.caption2.bold())
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            ForEach(viewModel.sortedProcesses) { process in
                HStack(spacing: 0) {
                    Text("\(process.pid)")
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 70, alignment: .leading)

                    HStack(spacing: 6) {
                        Image(systemName: "app.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(process.name)
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                    }
                    .frame(width: 170, alignment: .leading)

                    HStack(spacing: 4) {
                        cpuBar(process.cpuUsage)
                        Text(String(format: "%.1f", process.cpuUsage))
                            .font(.system(.caption, design: .monospaced))
                    }
                    .frame(width: 90)

                    Text(String(format: "%.0f MB", process.memoryMB))
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 110)

                    Text("\(process.threads)")
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 80)

                    Text(process.user)
                        .font(.caption)
                        .frame(width: 100, alignment: .leading)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(process.state == "Running" ? .green : .yellow)
                            .frame(width: 6, height: 6)
                        Text(process.state)
                            .font(.caption2)
                    }
                    .frame(width: 100)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .background(
                    hoveredPID == process.pid
                    ? Color.accentColor.opacity(0.12)
                    : (viewModel.sortedProcesses.firstIndex(where: { $0.id == process.id }).map { $0 % 2 == 0 } ?? false)
                        ? Color(nsColor: .controlBackgroundColor).opacity(0.45)
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .onHover { hovering in
                    hoveredPID = hovering ? process.pid : nil
                }
                .help("PID \(process.pid) • \(process.state) • CPU \(String(format: "%.1f", process.cpuUsage))%")
            }
        }
    }

    private func cpuBar(_ value: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color.secondary.opacity(0.2))

                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(cpuBarColor(value).gradient)
                    .frame(width: max(0, geo.size.width * min(value / 30, 1)))
            }
        }
        .frame(width: 24, height: 6)
    }

    private func cpuBarColor(_ value: Double) -> Color {
        if value > 20 { return .red }
        if value > 10 { return .orange }
        return .green
    }
}

private struct MonitorInsightPopover: View {
    let totalCPU: Double
    let processCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How to Read This Monitor")
                .font(.headline)

            Text("• CPU card shows aggregate active CPU across sampled processes.")
            Text("• Memory card estimates resident usage ratio.")
            Text("• Sort by CPU to identify hot processes quickly.")
            Text("• Thread count hints at concurrency intensity.")

            Divider()

            Text("Current Snapshot")
                .font(.subheadline.weight(.semibold))
            Text("Processes observed: \(processCount)")
            Text("Aggregate CPU sample: \(String(format: "%.1f", totalCPU))%")
        }
        .font(.caption)
    }
}
