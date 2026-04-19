import Foundation
import SwiftUI

final class BackendSchedulingService {
    static let shared = BackendSchedulingService()

    #if USE_CPU_BACKEND
    private let schedulerBridge = SchedulerBridge.shared()
    #endif

    private init() {}

    func schedule(
        algorithm: AlgorithmInfo,
        processes: [SchedulerProcess],
        timeQuantum: Int
    ) -> SchedulingResult? {
        guard !processes.isEmpty else {
            return nil
        }

        #if USE_CPU_BACKEND
        let bridgeProcesses = processes.map { process in
            let bridge = BridgeProcess()
            bridge.processID = Int32(process.processID)
            bridge.name = process.name
            bridge.arrivalTime = Int32(process.arrivalTime)
            bridge.burstTime = Int32(process.burstTime)
            bridge.priority = Int32(process.priority)
            return bridge
        }

        guard let result = schedulerBridge.scheduleProcesses(
            bridgeProcesses,
            with: mapAlgorithm(algorithm.id),
            timeQuantum: Int32(max(1, timeQuantum))
        ) else {
            return nil
        }

        return convert(result: result, algorithm: algorithm)
        #else
        return MockDataService.shared.generateMockResult(
            for: algorithm,
            processes: processes,
            timeQuantum: timeQuantum
        )
        #endif
    }

    func compare(
        algorithms: [AlgorithmInfo],
        processes: [SchedulerProcess],
        timeQuantum: Int
    ) -> [SchedulingResult] {
        algorithms.compactMap { algorithm in
            schedule(algorithm: algorithm, processes: processes, timeQuantum: timeQuantum)
        }
    }

    #if USE_CPU_BACKEND
    private func mapAlgorithm(_ id: String) -> SchedulingAlgorithmType {
        let rawValue: Int
        switch id {
        case "fcfs":
            rawValue = 0
        case "sjf":
            rawValue = 1
        case "srtf":
            rawValue = 2
        case "rr":
            rawValue = 3
        case "priority_np":
            rawValue = 4
        case "priority_p":
            rawValue = 5
        default:
            rawValue = 0
        }

        return SchedulingAlgorithmType(rawValue: rawValue) ?? SchedulingAlgorithmType(rawValue: 0)!
    }

    private func convert(result: BridgeSchedulingResult, algorithm: AlgorithmInfo) -> SchedulingResult {
        let timeline = result.timeline.map { event in
            TimelineEvent(
                id: UUID(),
                processID: Int(event.processID),
                processName: event.processName,
                startTime: Int(event.startTime),
                endTime: Int(event.endTime),
                color: SchedulerProcess.colorForProcess(Int(event.processID))
            )
        }

        let processMetrics = result.metrics.processMetrics.compactMap { item -> ProcessMetric? in
            guard let dict = item as? [String: Any] else {
                return nil
            }

            return ProcessMetric(
                id: UUID(),
                processName: stringValue(dict["processName"], fallback: "P?"),
                arrivalTime: intValue(dict["arrivalTime"]),
                burstTime: intValue(dict["burstTime"]),
                completionTime: intValue(dict["completionTime"]),
                turnaroundTime: intValue(dict["turnaroundTime"]),
                waitingTime: intValue(dict["waitingTime"]),
                responseTime: intValue(dict["responseTime"])
            )
        }

        let metrics = PerformanceMetrics(
            averageTurnaroundTime: result.metrics.averageTurnaroundTime,
            averageWaitingTime: result.metrics.averageWaitingTime,
            averageResponseTime: result.metrics.averageResponseTime,
            cpuUtilization: result.metrics.cpuUtilization,
            throughput: result.metrics.throughput,
            totalTime: Int(result.metrics.totalTime),
            contextSwitches: Int(result.metrics.contextSwitches),
            processMetrics: processMetrics
        )

        return SchedulingResult(
            algorithm: algorithm,
            timeline: timeline,
            metrics: metrics
        )
    }

    private func intValue(_ value: Any?) -> Int {
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let intValue = value as? Int {
            return intValue
        }
        if let stringValue = value as? String, let parsed = Int(stringValue) {
            return parsed
        }
        return 0
    }

    private func stringValue(_ value: Any?, fallback: String) -> String {
        if let stringValue = value as? String, !stringValue.isEmpty {
            return stringValue
        }
        return fallback
    }
    #endif
}
