import SwiftUI
import Combine

// MARK: - System Monitor View Model
class MonitorViewModel: ObservableObject {
    struct SystemProcessSnapshot: Identifiable {
        let pid: Int
        let name: String
        let cpuUsage: Double
        let memoryMB: Double
        let threads: Int
        let state: String
        let user: String

        var id: Int { pid }
    }

    @Published var processes: [SystemProcessSnapshot] = []
    @Published var cpuHistory: [Double] = []
    @Published var memoryUsage: Double = 0
    @Published var totalCPU: Double = 0
    @Published var sortOrder: SortOrder = .cpu

    private let maxHistoryPoints = 60

    #if USE_CPU_BACKEND
    private let monitorBridge = ProcessMonitorBridge.shared()
    private let assumedTotalMemoryMB = 32_768.0
    #else
    private var timer: AnyCancellable?
    #endif

    enum SortOrder: String, CaseIterable {
        case cpu = "CPU %"
        case memory = "Memory"
        case name = "Name"
        case pid = "PID"
    }

    init() {
        #if USE_CPU_BACKEND
        cpuHistory = Array(repeating: 0, count: maxHistoryPoints)
        refreshSnapshot()
        #else
        processes = MockDataService.generateMockSystemProcesses().map {
            SystemProcessSnapshot(
                pid: $0.pid,
                name: $0.name,
                cpuUsage: $0.cpuUsage,
                memoryMB: $0.memoryMB,
                threads: $0.threads,
                state: $0.state,
                user: $0.user
            )
        }
        cpuHistory = (0..<maxHistoryPoints).map { _ in Double.random(in: 15...65) }
        memoryUsage = 68.5
        updateTotalCPU()
        #endif
    }

    func startMonitoring() {
        #if USE_CPU_BACKEND
        monitorBridge.startMonitoring(withInterval: 2.0) { [weak self] updatedProcesses in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.applySnapshot(updatedProcesses)
            }
        }
        #else
        timer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMockData()
            }
        #endif
    }

    func stopMonitoring() {
        #if USE_CPU_BACKEND
        monitorBridge.stopMonitoring()
        #else
        timer?.cancel()
        timer = nil
        #endif
    }

    #if USE_CPU_BACKEND
    private func refreshSnapshot() {
        applySnapshot(monitorBridge.getAllProcesses())
    }

    private func applySnapshot(_ bridgeProcesses: [BridgeSystemProcess]) {
        let converted = bridgeProcesses.map { process in
            SystemProcessSnapshot(
                pid: Int(process.pid),
                name: process.name,
                cpuUsage: max(0, process.cpuUsage),
                memoryMB: Double(process.memoryUsage) / 1_048_576.0,
                threads: Int(process.threadCount),
                state: process.state.capitalized,
                user: process.user.isEmpty ? "unknown" : process.user
            )
        }

        processes = converted

        let aggregateCPU = min(100.0, converted.reduce(0.0) { $0 + $1.cpuUsage })
        totalCPU = aggregateCPU

        cpuHistory.append(aggregateCPU)
        if cpuHistory.count > maxHistoryPoints {
            cpuHistory.removeFirst(cpuHistory.count - maxHistoryPoints)
        }

        let residentMemoryMB = converted.reduce(0.0) { $0 + $1.memoryMB }
        memoryUsage = max(0.0, min(100.0, (residentMemoryMB / assumedTotalMemoryMB) * 100.0))
    }
    #else
    private func updateMockData() {
        for i in processes.indices {
            let fluctuation = Double.random(in: -2...2)
            let newCPU = max(0, min(100, processes[i].cpuUsage + fluctuation))
            processes[i] = SystemProcessSnapshot(
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
        if cpuHistory.count > maxHistoryPoints {
            cpuHistory.removeFirst(cpuHistory.count - maxHistoryPoints)
        }

        memoryUsage = max(50, min(95, memoryUsage + Double.random(in: -1...1)))
        updateTotalCPU()
    }
    #endif

    private func updateTotalCPU() {
        totalCPU = processes.reduce(0) { $0 + $1.cpuUsage }
    }

    var sortedProcesses: [SystemProcessSnapshot] {
        switch sortOrder {
        case .cpu:
            return processes.sorted { $0.cpuUsage > $1.cpuUsage }
        case .memory:
            return processes.sorted { $0.memoryMB > $1.memoryMB }
        case .name:
            return processes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .pid:
            return processes.sorted { $0.pid < $1.pid }
        }
    }
}
