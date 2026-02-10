import SwiftUI
import Combine

// MARK: - Comparison View Model
class ComparisonViewModel: ObservableObject {
    @Published var processes: [SchedulerProcess] = []
    @Published var selectedAlgorithms: Set<String> = ["fcfs", "sjf", "rr"]
    @Published var timeQuantum: Int = 4
    @Published var results: [SchedulingResult] = []
    @Published var isRunning = false

    var selectedAlgorithmInfos: [AlgorithmInfo] {
        AlgorithmInfo.all.filter { selectedAlgorithms.contains($0.id) }
    }

    func toggleAlgorithm(_ algorithm: AlgorithmInfo) {
        if selectedAlgorithms.contains(algorithm.id) {
            selectedAlgorithms.remove(algorithm.id)
        } else {
            selectedAlgorithms.insert(algorithm.id)
        }
    }

    func loadScenario(_ scenario: [SchedulerProcess]) {
        withAnimation {
            processes = scenario
            results = []
        }
    }

    func generateRandomProcesses() {
        let count = Int.random(in: 4...6)
        processes = (1...count).map { i in
            SchedulerProcess(
                processID: i,
                arrivalTime: Int.random(in: 0...8),
                burstTime: Int.random(in: 2...12),
                priority: Int.random(in: 1...10)
            )
        }
        withAnimation {
            results = []
        }
    }

    func runComparison() {
        guard !processes.isEmpty, !selectedAlgorithms.isEmpty else { return }
        isRunning = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let newResults = self.selectedAlgorithmInfos.map { algo in
                MockDataService.shared.generateMockResult(
                    for: algo,
                    processes: self.processes,
                    timeQuantum: self.timeQuantum
                )
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                self.results = newResults
                self.isRunning = false
            }
        }
    }
}
