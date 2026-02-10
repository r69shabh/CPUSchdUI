import SwiftUI
import Charts

// MARK: - System Monitor View
struct SystemMonitorView: View {
    @StateObject private var viewModel = MonitorViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            monitorToolbar

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    // CPU & Memory overview
                    overviewCards
                        .padding(.horizontal, 24)

                    // CPU History Chart
                    cpuHistoryChart
                        .padding(.horizontal, 24)

                    Divider()
                        .padding(.horizontal, 24)

                    // Process list
                    processListSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
                .padding(.top, 20)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { viewModel.startMonitoring() }
        .onDisappear { viewModel.stopMonitoring() }
    }

    // MARK: - Toolbar
    private var monitorToolbar: some View {
        HStack(spacing: 16) {
            Label("System Monitor", systemImage: "waveform.path.ecg")
                .font(.headline)

            PulseDot(color: .green)

            Text("Live")
                .font(.caption.bold())
                .foregroundStyle(.green)

            Spacer()

            Picker("Sort by", selection: $viewModel.sortOrder) {
                ForEach(MonitorViewModel.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
    }

    // MARK: - Overview Cards
    private var overviewCards: some View {
        HStack(spacing: 16) {
            // CPU usage card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "cpu")
                        .foregroundStyle(.blue.gradient)
                    Text("CPU Usage")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", viewModel.cpuHistory.last ?? 0))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                        .contentTransition(.numericText())
                    Text("%")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                // Mini sparkline
                Chart(Array(viewModel.cpuHistory.suffix(20).enumerated()), id: \.offset) { index, value in
                    LineMark(
                        x: .value("Time", index),
                        y: .value("CPU", value)
                    )
                    .foregroundStyle(.blue.gradient)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Time", index),
                        y: .value("CPU", value)
                    )
                    .foregroundStyle(.blue.opacity(0.1).gradient)
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: 0...100)
                .frame(height: 50)
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Memory usage card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "memorychip")
                        .foregroundStyle(.purple.gradient)
                    Text("Memory Usage")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", viewModel.memoryUsage))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)
                        .contentTransition(.numericText())
                    Text("%")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                // Memory bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.secondary.opacity(0.2))

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(.purple.gradient)
                            .frame(width: geo.size.width * viewModel.memoryUsage / 100)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("Used: \(String(format: "%.1f", viewModel.memoryUsage * 0.32)) GB")
                    Spacer()
                    Text("Total: 32 GB")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Process count card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "square.stack.3d.up")
                        .foregroundStyle(.orange.gradient)
                    Text("Processes")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }

                Text("\(viewModel.processes.count)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle().fill(.green).frame(width: 6, height: 6)
                        Text("Running: \(viewModel.processes.filter { $0.state == "Running" }.count)")
                    }
                    HStack(spacing: 4) {
                        Circle().fill(.yellow).frame(width: 6, height: 6)
                        Text("Sleeping: \(viewModel.processes.filter { $0.state == "Sleeping" }.count)")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - CPU History Chart
    private var cpuHistoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CPU Usage History")
                .font(.headline)

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
                        colors: [.blue.opacity(0.2), .blue.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 0...100)
            .chartYAxisLabel("%")
            .chartXAxisLabel("Time (seconds ago)")
            .frame(height: 180)
            .chartPlotStyle { plot in
                plot.background(Color.secondary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Process List
    private var processListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Active Processes")
                .font(.headline)

            // Table header
            HStack(spacing: 0) {
                Text("PID").frame(width: 60, alignment: .leading)
                Text("Name").frame(width: 140, alignment: .leading)
                Text("CPU %").frame(width: 80)
                Text("Memory").frame(width: 100)
                Text("Threads").frame(width: 70)
                Text("User").frame(width: 90, alignment: .leading)
                Text("State").frame(width: 80)
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
                        .frame(width: 60, alignment: .leading)

                    HStack(spacing: 6) {
                        Image(systemName: "app.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(process.name)
                            .font(.caption.weight(.medium))
                    }
                    .frame(width: 140, alignment: .leading)

                    HStack(spacing: 4) {
                        cpuBar(process.cpuUsage)
                        Text(String(format: "%.1f", process.cpuUsage))
                            .font(.system(.caption, design: .monospaced))
                    }
                    .frame(width: 80)

                    Text(String(format: "%.0f MB", process.memoryMB))
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 100)

                    Text("\(process.threads)")
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 70)

                    Text(process.user)
                        .font(.caption)
                        .frame(width: 90, alignment: .leading)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(process.state == "Running" ? .green : .yellow)
                            .frame(width: 6, height: 6)
                        Text(process.state)
                            .font(.caption2)
                    }
                    .frame(width: 80)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .background(
                    viewModel.sortedProcesses.firstIndex(where: { $0.id == process.id }).map { $0 % 2 == 0 } ?? false
                        ? Color(nsColor: .controlBackgroundColor).opacity(0.5)
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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
