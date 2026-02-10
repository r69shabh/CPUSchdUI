import Foundation

// MARK: - Performance Metrics
struct PerformanceMetrics {
    var averageTurnaroundTime: Double
    var averageWaitingTime: Double
    var averageResponseTime: Double
    var cpuUtilization: Double
    var throughput: Double
    var totalTime: Int
    var contextSwitches: Int

    var processMetrics: [ProcessMetric]
}

// MARK: - Per-Process Metric
struct ProcessMetric: Identifiable {
    let id: UUID
    let processName: String
    let arrivalTime: Int
    let burstTime: Int
    let completionTime: Int
    let turnaroundTime: Int
    let waitingTime: Int
    let responseTime: Int
}
