import SwiftUI

// MARK: - Algorithm Info
struct AlgorithmInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let description: String
    let isPreemptive: Bool
    let needsQuantum: Bool
    let color: Color
    let icon: String

    static func == (lhs: AlgorithmInfo, rhs: AlgorithmInfo) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static let all: [AlgorithmInfo] = [
        AlgorithmInfo(
            id: "fcfs",
            name: "First-Come, First-Served",
            shortName: "FCFS",
            description: "Non-preemptive. Processes executed in arrival order. Simple but can cause convoy effect.",
            isPreemptive: false,
            needsQuantum: false,
            color: AppColors.fcfs,
            icon: "arrow.right.circle.fill"
        ),
        AlgorithmInfo(
            id: "sjf",
            name: "Shortest Job First",
            shortName: "SJF",
            description: "Non-preemptive. Selects process with shortest burst time. Optimal average waiting time for non-preemptive.",
            isPreemptive: false,
            needsQuantum: false,
            color: AppColors.sjf,
            icon: "arrow.down.circle.fill"
        ),
        AlgorithmInfo(
            id: "srtf",
            name: "Shortest Remaining Time First",
            shortName: "SRTF",
            description: "Preemptive SJF. Switches to shortest remaining time. Provides optimal average waiting time.",
            isPreemptive: true,
            needsQuantum: false,
            color: AppColors.srtf,
            icon: "timer.circle.fill"
        ),
        AlgorithmInfo(
            id: "rr",
            name: "Round Robin",
            shortName: "RR",
            description: "Preemptive. Equal time quantum for all processes. Good response time, fair allocation.",
            isPreemptive: true,
            needsQuantum: true,
            color: AppColors.roundRobin,
            icon: "arrow.triangle.2.circlepath.circle.fill"
        ),
        AlgorithmInfo(
            id: "priority_np",
            name: "Priority (Non-Preemptive)",
            shortName: "Priority NP",
            description: "Selects highest priority process. Non-preemptive. May cause starvation of low-priority processes.",
            isPreemptive: false,
            needsQuantum: false,
            color: AppColors.priorityNP,
            icon: "star.circle.fill"
        ),
        AlgorithmInfo(
            id: "priority_p",
            name: "Priority (Preemptive)",
            shortName: "Priority P",
            description: "Switches to highest priority immediately. Responsive but may starve low-priority processes.",
            isPreemptive: true,
            needsQuantum: false,
            color: AppColors.priorityP,
            icon: "star.leadinghalf.filled"
        ),
    ]
}
