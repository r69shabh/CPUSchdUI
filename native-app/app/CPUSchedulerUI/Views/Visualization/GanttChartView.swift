import SwiftUI
import Charts

// MARK: - Gantt Chart Section
struct GanttChartSection: View {
    @EnvironmentObject private var preferences: PreferencesService

    let result: SchedulingResult

    @State private var hoveredEvent: TimelineEvent?
    @State private var selectedEvent: TimelineEvent?
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Label("Timeline Visualization", systemImage: "chart.bar.xaxis")
                    .font(.headline)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: result.algorithm.icon)
                        .foregroundStyle(result.algorithm.color)
                    Text(result.algorithm.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(result.algorithm.color.opacity(0.1))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            ganttChart
                .frame(height: 280)
                .padding(.horizontal, 20)

            if preferences.showTooltips {
                hoverInsightPanel
                    .padding(.horizontal, 20)
            }

            timelineChips
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.84)) {
                appeared = true
            }
        }
        .popover(item: $selectedEvent) { event in
            TimelinePopover(event: event)
                .frame(width: 300)
                .padding(16)
        }
    }

    // MARK: - Gantt Chart
    private var ganttChart: some View {
        Chart {
            ForEach(result.timeline) { event in
                BarMark(
                    xStart: .value("Start", event.startTime),
                    xEnd: .value("End", event.endTime),
                    y: .value("Process", event.processName)
                )
                .foregroundStyle(event.color.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .opacity(hoveredEvent == nil || hoveredEvent?.id == event.id ? 1.0 : 0.4)
                .annotation(position: .overlay) {
                    if event.duration >= 2 {
                        Text("\(event.duration)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 14)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 4]))
                    .foregroundStyle(Color.secondary.opacity(0.25))
                AxisTick()
                AxisValueLabel {
                    if let time = value.as(Int.self) {
                        Text("\(time)")
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let processName = value.as(String.self) {
                        Text(processName)
                            .font(.caption.bold())
                    }
                }
            }
        }
        .chartXAxisLabel(position: .bottom) {
            Text("Time")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var hoverInsightPanel: some View {
        Group {
            if let hoveredEvent {
                HStack(spacing: 8) {
                    Circle()
                        .fill(hoveredEvent.color)
                        .frame(width: 8, height: 8)
                    Text("\(hoveredEvent.processName) ran from t=\(hoveredEvent.startTime) to t=\(hoveredEvent.endTime).")
                        .font(.caption)
                    Spacer()
                    Text("Duration: \(hoveredEvent.duration)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                Text("Hover or click a sequence chip to inspect why a specific segment appears.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Timeline Chips
    private var timelineChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Execution Sequence")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(result.timeline.count) segments · \(result.metrics.contextSwitches) switches")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(result.timeline.enumerated()), id: \.element.id) { index, event in
                        TimelineEventChip(
                            event: event,
                            index: index,
                            isHovered: hoveredEvent?.id == event.id
                        )
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.12)) {
                                hoveredEvent = hovering ? event : nil
                            }
                        }
                        .onTapGesture {
                            selectedEvent = event
                        }
                        .help("Click for explanation")
                    }
                }
            }
        }
    }
}

// MARK: - Timeline Event Chip
struct TimelineEventChip: View {
    let event: TimelineEvent
    let index: Int
    let isHovered: Bool

    var body: some View {
        HStack(spacing: 6) {
            if index > 0 {
                Image(systemName: "arrow.right")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.secondary.opacity(0.3))
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(event.color.gradient)
                        .frame(width: 7, height: 7)

                    Text(event.processName)
                        .font(.caption2.bold())
                }

                Text("t=\(event.startTime)–\(event.endTime)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(event.color.opacity(isHovered ? 0.26 : 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(event.color.opacity(isHovered ? 0.6 : 0), lineWidth: 1.2)
            }
            .scaleEffect(isHovered ? 1.04 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.82), value: isHovered)
        }
    }
}

private struct TimelinePopover: View {
    let event: TimelineEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(event.color)
                    .frame(width: 10, height: 10)
                Text(event.processName)
                    .font(.headline)
            }

            Text("CPU slice: t=\(event.startTime) to t=\(event.endTime)")
                .font(.subheadline)

            Text("Duration: \(event.duration) unit\(event.duration == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text(explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var explanation: String {
        if event.duration == 1 {
            return "Short slices often happen in preemptive scheduling or small RR quantums."
        }
        if event.duration >= 6 {
            return "Long uninterrupted execution suggests low preemption pressure for this process."
        }
        return "This segment reflects one scheduler decision window before the next potential switch."
    }
}
