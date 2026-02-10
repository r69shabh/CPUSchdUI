import SwiftUI
import Combine

// MARK: - Simulator View Model
class SimulatorViewModel: ObservableObject {
    @Published var processes: [SchedulerProcess] = []
    @Published var selectedAlgorithm: AlgorithmInfo = AlgorithmInfo.all[0]
    @Published var timeQuantum: Int = 4
    @Published var currentResult: SchedulingResult?
    @Published var isRunning = false
    @Published var animationProgress: Double = 0

    func addProcess(arrivalTime: Int, burstTime: Int, priority: Int) {
        let newProcess = SchedulerProcess(
            processID: processes.count + 1,
            arrivalTime: arrivalTime,
            burstTime: burstTime,
            priority: priority
        )
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            processes.append(newProcess)
        }
    }

    func removeProcess(_ process: SchedulerProcess) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            processes.removeAll { $0.id == process.id }
        }
        // Re-number processes
        for i in processes.indices {
            processes[i].processID = i + 1
            processes[i].name = "P\(i + 1)"
            processes[i].color = SchedulerProcess.colorForProcess(i + 1)
        }
    }

    func clearAll() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            processes.removeAll()
            currentResult = nil
            animationProgress = 0
        }
    }

    func loadScenario(_ scenario: [SchedulerProcess]) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            processes = scenario
            currentResult = nil
            animationProgress = 0
        }
    }

    func generateRandomProcesses() {
        let count = Int.random(in: 4...8)
        let newProcesses = (1...count).map { i in
            SchedulerProcess(
                processID: i,
                arrivalTime: Int.random(in: 0...10),
                burstTime: Int.random(in: 2...15),
                priority: Int.random(in: 1...10)
            )
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            processes = newProcesses
            currentResult = nil
            animationProgress = 0
        }
    }

    func runSimulation() {
        guard !processes.isEmpty else { return }
        isRunning = true
        animationProgress = 0

        // Simulate a brief processing delay for UX polish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }

            let result = MockDataService.shared.generateMockResult(
                for: self.selectedAlgorithm,
                processes: self.processes,
                timeQuantum: self.timeQuantum
            )

            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                self.currentResult = result
                self.isRunning = false
            }

            // Animate progress bar
            withAnimation(.easeInOut(duration: 1.0)) {
                self.animationProgress = 1.0
            }
        }
    }
}
