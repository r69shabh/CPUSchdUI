import SwiftUI
import Combine

// MARK: - System Monitor View Model
class MonitorViewModel: ObservableObject {
    @Published var processes: [MockDataService.MockSystemProcess] = []
    @Published var cpuHistory: [Double] = []
    @Published var memoryUsage: Double = 0
    @Published var totalCPU: Double = 0
    @Published var sortOrder: SortOrder = .cpu

    private var timer: AnyCancellable?

    enum SortOrder: String, CaseIterable {
        case cpu = "CPU %"
        case memory = "Memory"
        case name = "Name"
        case pid = "PID"
    }

    init() {
        processes = MockDataService.generateMockSystemProcesses()
        cpuHistory = (0..<60).map { _ in Double.random(in: 15...65) }
        memoryUsage = 68.5
        updateTotalCPU()
    }

    func startMonitoring() {
        timer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMockData()
            }
    }

    func stopMonitoring() {
        timer?.cancel()
        timer = nil
    }

    private func updateMockData() {
        // Slightly fluctuate CPU usage for realism
        for i in processes.indices {
            let fluctuation = Double.random(in: -2...2)
            let newCPU = max(0, min(100, processes[i].cpuUsage + fluctuation))
            processes[i] = MockDataService.MockSystemProcess(
                pid: processes[i].pid,
                name: processes[i].name,
                cpuUsage: newCPU,
                memoryMB: processes[i].memoryMB + Double.random(in: -5...5),
                threads: processes[i].threads,
                state: processes[i].state,
                user: processes[i].user
            )
        }

        let newCPUValue = Double.random(in: 20...60)
        cpuHistory.append(newCPUValue)
        if cpuHistory.count > 60 {
            cpuHistory.removeFirst()
        }

        memoryUsage = max(50, min(95, memoryUsage + Double.random(in: -1...1)))
        updateTotalCPU()
    }

    private func updateTotalCPU() {
        totalCPU = processes.reduce(0) { $0 + $1.cpuUsage }
    }

    var sortedProcesses: [MockDataService.MockSystemProcess] {
        switch sortOrder {
        case .cpu:
            return processes.sorted { $0.cpuUsage > $1.cpuUsage }
        case .memory:
            return processes.sorted { $0.memoryMB > $1.memoryMB }
        case .name:
            return processes.sorted { $0.name < $1.name }
        case .pid:
            return processes.sorted { $0.pid < $1.pid }
        }
    }
}
