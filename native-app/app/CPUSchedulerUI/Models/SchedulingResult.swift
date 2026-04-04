import Foundation

// MARK: - Scheduling Result
struct SchedulingResult: Identifiable {
    let id: UUID
    let algorithm: AlgorithmInfo
    let timeline: [TimelineEvent]
    let metrics: PerformanceMetrics
    let timestamp: Date

    init(algorithm: AlgorithmInfo, timeline: [TimelineEvent], metrics: PerformanceMetrics) {
        self.id = UUID()
        self.algorithm = algorithm
        self.timeline = timeline
        self.metrics = metrics
        self.timestamp = Date()
    }
}
