import SwiftUI

// MARK: - Add Process Sheet
struct AddProcessSheet: View {
    @ObservedObject var viewModel: SimulatorViewModel
    @Environment(\.dismiss) var dismiss

    @State private var arrivalTime = 0
    @State private var burstTime = 5
    @State private var priority = 5

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add New Process")
                        .font(.title2.bold())
                    Text("Configure process parameters")
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

            // Form
            VStack(spacing: 20) {
                // Arrival Time
                parameterRow(
                    icon: "clock",
                    title: "Arrival Time",
                    subtitle: "When the process enters the ready queue",
                    value: $arrivalTime,
                    range: 0...100,
                    color: .blue
                )

                // Burst Time
                parameterRow(
                    icon: "speedometer",
                    title: "Burst Time",
                    subtitle: "CPU time needed to complete",
                    value: $burstTime,
                    range: 1...50,
                    color: .orange
                )

                // Priority
                parameterRow(
                    icon: "star.fill",
                    title: "Priority",
                    subtitle: "Higher number = higher priority",
                    value: $priority,
                    range: 1...10,
                    color: .purple
                )
            }
            .padding(24)

            Divider()

            // Preview
            VStack(alignment: .leading, spacing: 10) {
                Text("Preview")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                ProcessRow(
                    process: SchedulerProcess(
                        processID: viewModel.processes.count + 1,
                        arrivalTime: arrivalTime,
                        burstTime: burstTime,
                        priority: priority
                    ),
                    onDelete: {}
                )
                .allowsHitTesting(false)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Spacer()

            // Actions
            Divider()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button(action: {
                    viewModel.addProcess(
                        arrivalTime: arrivalTime,
                        burstTime: burstTime,
                        priority: priority
                    )
                    dismiss()
                }) {
                    Label("Add Process", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
            .padding(20)
        }
        .frame(width: 520, height: 540)
    }

    private func parameterRow(
        icon: String,
        title: String,
        subtitle: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        color: Color
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color.gradient)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Button(action: { if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Text("\(value.wrappedValue)")
                    .font(.system(.title3, design: .monospaced).bold())
                    .frame(width: 40, alignment: .center)

                Button(action: { if value.wrappedValue < range.upperBound { value.wrappedValue += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
