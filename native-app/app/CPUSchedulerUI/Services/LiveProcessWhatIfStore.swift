import Foundation
import Combine

struct LiveProcessCandidate: Identifiable, Hashable {
    let pid: Int
    let name: String
    let cpuUsage: Double
    let memoryMB: Double
    let threads: Int
    let user: String
    let state: String
    let nice: Int
    let startTimeEpochMS: UInt64
    var isSelected: Bool

    var id: Int { pid }
}

struct LiveSnapshotMeta {
    let capturedAt: Date
    let totalProcessesSeen: Int
    let selectedCount: Int
}

@MainActor
final class LiveProcessWhatIfStore: ObservableObject {
    @Published var all: [LiveProcessCandidate]
    @Published var autoRefreshEnabled: Bool {
        didSet {
            restartAutoRefreshTimer()
        }
    }
    @Published var refreshIntervalSeconds: Double {
        didSet {
            let normalized = Self.normalizedInterval(refreshIntervalSeconds)
            if normalized != refreshIntervalSeconds {
                refreshIntervalSeconds = normalized
                return
            }
            restartAutoRefreshTimer()
        }
    }
    @Published var lastSnapshot: LiveSnapshotMeta?

    #if USE_CPU_BACKEND
    private let monitorBridge = ProcessMonitorBridge.shared()
    #endif

    private var autoRefreshTimer: AnyCancellable?
    private let defaultPrefillCount = 12

    init(autoRefreshEnabled: Bool = false, refreshIntervalSeconds: Double = 5.0) {
        self.all = []
        self.autoRefreshEnabled = autoRefreshEnabled
        self.refreshIntervalSeconds = Self.normalizedInterval(refreshIntervalSeconds)
        self.lastSnapshot = nil

        refreshNow()
        restartAutoRefreshTimer()
    }

    func configure(autoRefreshEnabled: Bool, refreshIntervalSeconds: Double) {
        self.autoRefreshEnabled = autoRefreshEnabled
        self.refreshIntervalSeconds = Self.normalizedInterval(refreshIntervalSeconds)
    }

    func refreshNow() {
        let previousSelectionByPID = Dictionary(uniqueKeysWithValues: all.map { ($0.pid, $0.isSelected) })
        let hadExistingSnapshot = lastSnapshot != nil

        let fresh = fetchLiveCandidates()
        let sortedByActivity = Self.sortByActivity(fresh)
        let prefilledPIDs = Set(sortedByActivity.prefix(defaultPrefillCount).map(\.pid))

        all = sortedByActivity.map { candidate in
            var updated = candidate
            if let priorSelection = previousSelectionByPID[candidate.pid] {
                updated.isSelected = priorSelection
            } else {
                updated.isSelected = hadExistingSnapshot ? false : prefilledPIDs.contains(candidate.pid)
            }
            return updated
        }

        lastSnapshot = LiveSnapshotMeta(
            capturedAt: Date(),
            totalProcessesSeen: all.count,
            selectedCount: all.filter(\.isSelected).count
        )
    }

    func selectedAsSchedulerProcesses() -> [SchedulerProcess] {
        let ordered = all
            .filter(\.isSelected)
            .sorted {
                if $0.startTimeEpochMS == $1.startTimeEpochMS {
                    return $0.pid < $1.pid
                }
                return $0.startTimeEpochMS < $1.startTimeEpochMS
            }

        return ordered.enumerated().map { rank, process in
            let arrival = min(rank, 20)
            let burst = estimatedBurst(cpuUsage: process.cpuUsage, threads: process.threads)
            let priority = mapNiceToPriority(process.nice)

            return SchedulerProcess(
                processID: process.pid,
                name: process.name,
                arrivalTime: arrival,
                burstTime: burst,
                priority: priority
            )
        }
    }

    func setSelection(pid: Int, isSelected: Bool) {
        guard let index = all.firstIndex(where: { $0.pid == pid }) else {
            return
        }
        all[index].isSelected = isSelected
        syncSelectionMetaCount()
    }

    func toggleSelection(pid: Int) {
        guard let index = all.firstIndex(where: { $0.pid == pid }) else {
            return
        }
        all[index].isSelected.toggle()
        syncSelectionMetaCount()
    }

    func selectTopPrefill() {
        let topSet = Set(Self.sortByActivity(all).prefix(defaultPrefillCount).map(\.pid))
        for index in all.indices {
            all[index].isSelected = topSet.contains(all[index].pid)
        }
        syncSelectionMetaCount()
    }

    func selectAll() {
        for index in all.indices {
            all[index].isSelected = true
        }
        syncSelectionMetaCount()
    }

    func clearSelection() {
        for index in all.indices {
            all[index].isSelected = false
        }
        syncSelectionMetaCount()
    }

    private func syncSelectionMetaCount() {
        guard let previous = lastSnapshot else {
            return
        }

        lastSnapshot = LiveSnapshotMeta(
            capturedAt: previous.capturedAt,
            totalProcessesSeen: previous.totalProcessesSeen,
            selectedCount: all.filter(\.isSelected).count
        )
    }

    private func restartAutoRefreshTimer() {
        autoRefreshTimer?.cancel()
        autoRefreshTimer = nil

        guard autoRefreshEnabled else {
            return
        }

        let interval = Self.normalizedInterval(refreshIntervalSeconds)
        autoRefreshTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshNow()
            }
    }

    private func fetchLiveCandidates() -> [LiveProcessCandidate] {
        #if USE_CPU_BACKEND
        let nowMS = UInt64(Date().timeIntervalSince1970 * 1000)
        return monitorBridge.getAllProcesses().map { process in
            LiveProcessCandidate(
                pid: Int(process.pid),
                name: process.name,
                cpuUsage: max(0.0, process.cpuUsage),
                memoryMB: max(0.0, Double(process.memoryUsage) / 1_048_576.0),
                threads: max(0, Int(process.threadCount)),
                user: process.user.isEmpty ? "unknown" : process.user,
                state: process.state.capitalized,
                nice: Int(process.priority),
                startTimeEpochMS: process.startTimeEpochMS > 0 ? process.startTimeEpochMS : nowMS,
                isSelected: false
            )
        }
        #else
        let nowMS = UInt64(Date().timeIntervalSince1970 * 1000)
        return MockDataService.generateMockSystemProcesses().enumerated().map { index, process in
            LiveProcessCandidate(
                pid: process.pid,
                name: process.name,
                cpuUsage: process.cpuUsage,
                memoryMB: process.memoryMB,
                threads: process.threads,
                user: process.user,
                state: process.state,
                nice: 0,
                startTimeEpochMS: nowMS - UInt64(index * 1_000),
                isSelected: false
            )
        }
        #endif
    }

    private static func sortByActivity(_ processes: [LiveProcessCandidate]) -> [LiveProcessCandidate] {
        processes.sorted {
            if $0.cpuUsage != $1.cpuUsage {
                return $0.cpuUsage > $1.cpuUsage
            }
            if $0.memoryMB != $1.memoryMB {
                return $0.memoryMB > $1.memoryMB
            }
            return $0.pid < $1.pid
        }
    }

    private func estimatedBurst(cpuUsage: Double, threads: Int) -> Int {
        let cpuTerm = Int(ceil(cpuUsage / 4.0))
        let threadTerm = min(threads, 8) / 2
        return clamp(cpuTerm + threadTerm, min: 1, max: 25)
    }

    private func mapNiceToPriority(_ nice: Int) -> Int {
        let clampedNice = clamp(nice, min: -20, max: 20)
        return 1 + ((clampedNice + 20) * 9) / 40
    }

    private static func normalizedInterval(_ value: Double) -> Double {
        if value.isNaN || value.isInfinite {
            return 5.0
        }
        return max(1.0, value)
    }

    private func clamp(_ value: Int, min minValue: Int, max maxValue: Int) -> Int {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
