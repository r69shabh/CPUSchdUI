import SwiftUI
import Charts

// MARK: - Gantt Chart Section
struct GanttChartSection: View {
    let result: SchedulingResult
    @State private var hoveredEvent: TimelineEvent?
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .center) {
                Label("Timeline Visualization", systemImage: "chart.bar.xaxis")
                    .font(.headline)

                Spacer()

                // Algorithm badge
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
            .padding(.top, 20)

            // Gantt Chart using Swift Charts
            ganttChart
                .frame(height: 280)
                .padding(.horizontal, 20)

            // Timeline event chips
            timelineChips
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                appeared = true
            }
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
                .opacity(hoveredEvent == nil || hoveredEvent?.id == event.id ? 1.0 : 0.45)
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
            AxisMarks(values: .automatic(desiredCount: 15)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                    .foregroundStyle(Color.secondary.opacity(0.3))
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
        .chartXAxisLabel(position: .bottom, alignment: .center) {
            Text("Time Units")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    // MARK: - Timeline Chips
    private var timelineChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Execution Sequence")
                    .font(.caption.bold())
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
            // Connection line (not for first)
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
            .background(event.color.opacity(isHovered ? 0.25 : 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(event.color.opacity(isHovered ? 0.6 : 0), lineWidth: 1.5)
            }
            .scaleEffect(isHovered ? 1.06 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isHovered)
        }
    }
}
