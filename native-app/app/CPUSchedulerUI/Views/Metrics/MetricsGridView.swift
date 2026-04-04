import SwiftUI

// MARK: - Metrics Section
struct MetricsSection: View {
    let metrics: PerformanceMetrics
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            // System-wide metrics cards
            systemMetricsGrid

            Divider()
                .padding(.horizontal)

            // Per-process table
            processMetricsTable
        }
        .padding(20)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - System Metrics Grid
    private var systemMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("System Performance", systemImage: "gauge.with.dots.needle.bottom.50percent")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 12) {
                MetricCard(
                    title: "Avg Turnaround",
                    value: String(format: "%.2f", metrics.averageTurnaroundTime),
                    unit: "units",
                    color: .blue,
                    icon: "clock.arrow.circlepath"
                )

                MetricCard(
                    title: "Avg Waiting",
                    value: String(format: "%.2f", metrics.averageWaitingTime),
                    unit: "units",
                    color: .orange,
                    icon: "hourglass"
                )

                MetricCard(
                    title: "Avg Response",
                    value: String(format: "%.2f", metrics.averageResponseTime),
                    unit: "units",
                    color: .green,
                    icon: "bolt.fill"
                )

                MetricCard(
                    title: "CPU Utilization",
                    value: String(format: "%.1f", metrics.cpuUtilization),
                    unit: "%",
                    color: .purple,
                    icon: "cpu"
                )

                MetricCard(
                    title: "Throughput",
                    value: String(format: "%.3f", metrics.throughput),
                    unit: "proc/unit",
                    color: .red,
                    icon: "gauge.high"
                )

                MetricCard(
                    title: "Context Switches",
                    value: "\(metrics.contextSwitches)",
                    unit: "switches",
                    color: .cyan,
                    icon: "arrow.triangle.swap"
                )
            }
        }
    }

    // MARK: - Process Metrics Table
    private var processMetricsTable: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Per-Process Metrics", systemImage: "tablecells")
                .font(.headline)

            // Table header
            HStack(spacing: 0) {
                tableHeaderCell("Process", width: 80)
                tableHeaderCell("Arrival", width: 65)
                tableHeaderCell("Burst", width: 55)
                tableHeaderCell("Completion", width: 90)
                tableHeaderCell("TAT", width: 55, color: .blue)
                tableHeaderCell("Waiting", width: 65, color: .orange)
                tableHeaderCell("Response", width: 75, color: .green)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            // Table rows
            ForEach(metrics.processMetrics) { metric in
                HStack(spacing: 0) {
                    Text(metric.processName)
                        .font(.system(.caption, design: .rounded).bold())
                        .frame(width: 80, alignment: .leading)

                    Text("\(metric.arrivalTime)")
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 65)

                    Text("\(metric.burstTime)")
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 55)

                    Text("\(metric.completionTime)")
                        .font(.system(.caption, design: .monospaced))
                        .frame(width: 90)

                    Text("\(metric.turnaroundTime)")
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundStyle(.blue)
                        .frame(width: 55)

                    Text("\(metric.waitingTime)")
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundStyle(.orange)
                        .frame(width: 65)

                    Text("\(metric.responseTime)")
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundStyle(.green)
                        .frame(width: 75)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    metrics.processMetrics.firstIndex(where: { $0.id == metric.id }).map { $0 % 2 == 0 } ?? false
                        ? Color(nsColor: .controlBackgroundColor).opacity(0.5)
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
    }

    private func tableHeaderCell(_ title: String, width: CGFloat, color: Color? = nil) -> some View {
        Text(title)
            .font(.caption2.bold())
            .foregroundStyle(color ?? .secondary)
            .frame(width: width, alignment: title == "Process" ? .leading : .center)
    }
}
