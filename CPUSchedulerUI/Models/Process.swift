import SwiftUI

// MARK: - Process Model
struct SchedulerProcess: Identifiable, Hashable {
    let id: UUID
    var processID: Int
    var name: String
    var arrivalTime: Int
    var burstTime: Int
    var priority: Int
    var color: Color

    // Display states
    var isRunning: Bool = false
    var isWaiting: Bool = false
    var isCompleted: Bool = false

    init(
        id: UUID = UUID(),
        processID: Int,
        name: String? = nil,
        arrivalTime: Int,
        burstTime: Int,
        priority: Int = 5
    ) {
        self.id = id
        self.processID = processID
        self.name = name ?? "P\(processID)"
        self.arrivalTime = arrivalTime
        self.burstTime = burstTime
        self.priority = priority
        self.color = SchedulerProcess.colorForProcess(processID)
    }

    static func colorForProcess(_ id: Int) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .pink,
            .cyan, .mint, .indigo, .teal, .yellow,
        ]
        return colors[id % colors.count]
    }

    // Hashable conformance
    static func == (lhs: SchedulerProcess, rhs: SchedulerProcess) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Timeline Event (for Gantt visualization)
struct TimelineEvent: Identifiable {
    let id: UUID
    let processID: Int
    let processName: String
    let startTime: Int
    let endTime: Int
    let color: Color

    var duration: Int { endTime - startTime }
}
