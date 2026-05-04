import SwiftUI

// MARK: - Mock Data Service
class MockDataService {
    static let shared = MockDataService()

    // MARK: - Generate Mock Results
    func generateMockResult(for algorithm: AlgorithmInfo, processes: [SchedulerProcess], timeQuantum: Int = 4) -> SchedulingResult {
        let timeline = generateMockTimeline(processes: processes, algorithm: algorithm, timeQuantum: timeQuantum)
        let totalTime = timeline.last?.endTime ?? 0
        let metrics = generateMockMetrics(processes: processes, totalTime: totalTime, timeline: timeline)

        return SchedulingResult(
            algorithm: algorithm,
            timeline: timeline,
            metrics: metrics
        )
    }

    private func generateMockTimeline(processes: [SchedulerProcess], algorithm: AlgorithmInfo, timeQuantum: Int) -> [TimelineEvent] {
        // Simple FCFS-like mock for demonstration
        var timeline: [TimelineEvent] = []
        var currentTime = 0
        let sorted = processes.sorted { $0.arrivalTime < $1.arrivalTime }

        if algorithm.needsQuantum {
            // Round-robin style mock
            var remaining: [(SchedulerProcess, Int)] = sorted.map { ($0, $0.burstTime) }
            var idx = 0
            var safety = 0
            while !remaining.isEmpty && safety < 200 {
                safety += 1
                let (proc, rem) = remaining[idx]
                if currentTime < proc.arrivalTime {
                    currentTime = proc.arrivalTime
                }
                let execTime = min(timeQuantum, rem)
                timeline.append(TimelineEvent(
                    id: UUID(),
                    processID: proc.processID,
                    processName: proc.name,
                    startTime: currentTime,
                    endTime: currentTime + execTime,
                    color: proc.color
                ))
                currentTime += execTime
                remaining[idx].1 -= execTime
                if remaining[idx].1 <= 0 {
                    remaining.remove(at: idx)
                    if !remaining.isEmpty {
                        idx = idx % remaining.count
                    }
                } else {
                    idx = (idx + 1) % remaining.count
                }
            }
        } else if algorithm.id.contains("priority") {
            // Priority-based mock
            var ready = sorted
            while !ready.isEmpty {
                let available = ready.filter { $0.arrivalTime <= currentTime }
                let next: SchedulerProcess
                if available.isEmpty {
                    next = ready[0]
                    currentTime = next.arrivalTime
                } else {
                    next = available.sorted { $0.priority > $1.priority }.first!
                }
                timeline.append(TimelineEvent(
                    id: UUID(),
                    processID: next.processID,
                    processName: next.name,
                    startTime: currentTime,
                    endTime: currentTime + next.burstTime,
                    color: next.color
                ))
                currentTime += next.burstTime
                ready.removeAll { $0.id == next.id }
            }
        } else if algorithm.id == "sjf" || algorithm.id == "srtf" {
            // SJF mock
            var ready = sorted
            while !ready.isEmpty {
                let available = ready.filter { $0.arrivalTime <= currentTime }
                let next: SchedulerProcess
                if available.isEmpty {
                    next = ready[0]
                    currentTime = next.arrivalTime
                } else {
                    next = available.sorted { $0.burstTime < $1.burstTime }.first!
                }
                timeline.append(TimelineEvent(
                    id: UUID(),
                    processID: next.processID,
                    processName: next.name,
                    startTime: currentTime,
                    endTime: currentTime + next.burstTime,
                    color: next.color
                ))
                currentTime += next.burstTime
                ready.removeAll { $0.id == next.id }
            }
        } else {
            // FCFS
            for process in sorted {
                if currentTime < process.arrivalTime {
                    currentTime = process.arrivalTime
                }
                timeline.append(TimelineEvent(
                    id: UUID(),
                    processID: process.processID,
                    processName: process.name,
                    startTime: currentTime,
                    endTime: currentTime + process.burstTime,
                    color: process.color
                ))
                currentTime += process.burstTime
            }
        }

        return timeline
    }

    private func generateMockMetrics(processes: [SchedulerProcess], totalTime: Int, timeline: [TimelineEvent]) -> PerformanceMetrics {
        // Build per-process completion times from timeline
        var completionTimes: [Int: Int] = [:]
        var responseTimes: [Int: Int] = [:]

        for event in timeline {
            completionTimes[event.processID] = event.endTime
            if responseTimes[event.processID] == nil {
                let proc = processes.first { $0.processID == event.processID }
                responseTimes[event.processID] = event.startTime - (proc?.arrivalTime ?? 0)
            }
        }

        let processMetrics: [ProcessMetric] = processes.map { process in
            let ct = completionTimes[process.processID] ?? (process.arrivalTime + process.burstTime)
            let tat = ct - process.arrivalTime
            let wt = max(0, tat - process.burstTime)
            let rt = responseTimes[process.processID] ?? wt

            return ProcessMetric(
                id: UUID(),
                processName: process.name,
                arrivalTime: process.arrivalTime,
                burstTime: process.burstTime,
                completionTime: ct,
                turnaroundTime: tat,
                waitingTime: wt,
                responseTime: rt
            )
        }

        let count = Double(processes.count)
        let avgTAT = processMetrics.reduce(0.0) { $0 + Double($1.turnaroundTime) } / max(count, 1)
        let avgWT = processMetrics.reduce(0.0) { $0 + Double($1.waitingTime) } / max(count, 1)
        let avgRT = processMetrics.reduce(0.0) { $0 + Double($1.responseTime) } / max(count, 1)
        let totalBurst = processes.reduce(0) { $0 + $1.burstTime }
        let cpuUtil = totalTime > 0 ? (Double(totalBurst) / Double(totalTime)) * 100.0 : 0
        let throughput = totalTime > 0 ? count / Double(totalTime) : 0

        return PerformanceMetrics(
            averageTurnaroundTime: avgTAT,
            averageWaitingTime: avgWT,
            averageResponseTime: avgRT,
            cpuUtilization: min(cpuUtil, 100),
            throughput: throughput,
            totalTime: totalTime,
            contextSwitches: max(1, timeline.count - 1),
            processMetrics: processMetrics
        )
    }

    // MARK: - Sample Scenarios
    static let scenarios: [(name: String, processes: [SchedulerProcess])] = [
        (
            name: "Basic FCFS",
            processes: [
                SchedulerProcess(processID: 1, arrivalTime: 0, burstTime: 5, priority: 3),
                SchedulerProcess(processID: 2, arrivalTime: 1, burstTime: 3, priority: 1),
                SchedulerProcess(processID: 3, arrivalTime: 2, burstTime: 8, priority: 2),
            ]
        ),
        (
            name: "SJF Optimization",
            processes: [
                SchedulerProcess(processID: 1, arrivalTime: 0, burstTime: 7, priority: 1),
                SchedulerProcess(processID: 2, arrivalTime: 2, burstTime: 4, priority: 2),
                SchedulerProcess(processID: 3, arrivalTime: 4, burstTime: 1, priority: 3),
                SchedulerProcess(processID: 4, arrivalTime: 5, burstTime: 4, priority: 1),
            ]
        ),
        (
            name: "Round Robin Demo",
            processes: [
                SchedulerProcess(processID: 1, arrivalTime: 0, burstTime: 10, priority: 1),
                SchedulerProcess(processID: 2, arrivalTime: 1, burstTime: 5, priority: 1),
                SchedulerProcess(processID: 3, arrivalTime: 2, burstTime: 8, priority: 1),
                SchedulerProcess(processID: 4, arrivalTime: 3, burstTime: 6, priority: 1),
            ]
        ),
        (
            name: "Priority Scheduling",
            processes: [
                SchedulerProcess(processID: 1, arrivalTime: 0, burstTime: 5, priority: 1),
                SchedulerProcess(processID: 2, arrivalTime: 1, burstTime: 10, priority: 10),
                SchedulerProcess(processID: 3, arrivalTime: 2, burstTime: 3, priority: 2),
                SchedulerProcess(processID: 4, arrivalTime: 3, burstTime: 4, priority: 1),
            ]
        ),
        (
            name: "Heavy Load",
            processes: [
                SchedulerProcess(processID: 1, arrivalTime: 0, burstTime: 15, priority: 5),
                SchedulerProcess(processID: 2, arrivalTime: 1, burstTime: 8, priority: 2),
                SchedulerProcess(processID: 3, arrivalTime: 2, burstTime: 12, priority: 7),
                SchedulerProcess(processID: 4, arrivalTime: 3, burstTime: 6, priority: 3),
                SchedulerProcess(processID: 5, arrivalTime: 4, burstTime: 10, priority: 4),
                SchedulerProcess(processID: 6, arrivalTime: 5, burstTime: 4, priority: 1),
            ]
        ),
    ]

    // MARK: - Tutorial Data
    static let tutorialModules: [TutorialModule] = [
        TutorialModule(
            title: "CPU Scheduling Basics",
            description: "Understand why CPU scheduling matters and core concepts.",
            icon: "cpu",
            steps: [
                TutorialStep(
                    title: "What is CPU Scheduling?",
                    content: "CPU scheduling determines which process runs on the CPU at any given time. When multiple processes compete for CPU time, the scheduler decides the order and duration of execution. Effective scheduling maximizes CPU utilization, minimizes waiting time, and ensures fairness.",
                    icon: "questionmark.circle.fill"
                ),
                TutorialStep(
                    title: "Key Terminology",
                    content: "• Arrival Time: When a process enters the ready queue\n• Burst Time: How long a process needs the CPU\n• Turnaround Time: Total time from arrival to completion\n• Waiting Time: Time spent waiting in the ready queue\n• Response Time: Time from arrival to first execution\n• Throughput: Number of processes completed per unit time",
                    icon: "text.book.closed.fill"
                ),
                TutorialStep(
                    title: "Preemptive vs Non-Preemptive",
                    content: "Non-preemptive: Once a process starts, it runs until completion or I/O.\nPreemptive: The OS can interrupt a running process to give CPU to another. Preemptive scheduling provides better responsiveness but adds context switch overhead.",
                    icon: "arrow.triangle.swap"
                ),
            ],
            quiz: [
                QuizQuestion(
                    question: "What does turnaround time measure?",
                    options: ["Time the process waits in queue", "Total time from arrival to completion", "Time for first response", "CPU burst duration"],
                    correctIndex: 1,
                    explanation: "Turnaround time is the total time from when a process arrives to when it completes execution."
                ),
                QuizQuestion(
                    question: "Which type of scheduling can interrupt a running process?",
                    options: ["Non-preemptive", "Preemptive", "Both", "Neither"],
                    correctIndex: 1,
                    explanation: "Preemptive scheduling allows the OS to interrupt a running process to schedule a higher-priority or shorter process."
                ),
            ]
        ),
        TutorialModule(
            title: "FCFS & SJF",
            description: "Learn about First-Come First-Served and Shortest Job First.",
            icon: "arrow.right.circle.fill",
            steps: [
                TutorialStep(
                    title: "First-Come, First-Served (FCFS)",
                    content: "The simplest scheduling algorithm. Processes are executed in the order they arrive. Like a queue at a grocery store — whoever arrives first gets served first.\n\nPros: Simple, fair, no starvation\nCons: Convoy effect (short processes wait behind long ones), high average waiting time",
                    icon: "arrow.right.circle.fill",
                    highlightAlgorithm: "fcfs"
                ),
                TutorialStep(
                    title: "Shortest Job First (SJF)",
                    content: "Selects the process with the shortest burst time next. Provably optimal for minimizing average waiting time among non-preemptive algorithms.\n\nPros: Optimal average waiting time\nCons: Requires knowing burst times in advance, can cause starvation of long processes",
                    icon: "arrow.down.circle.fill",
                    highlightAlgorithm: "sjf"
                ),
            ],
            quiz: [
                QuizQuestion(
                    question: "What is the main disadvantage of FCFS?",
                    options: ["Starvation", "Convoy effect", "Complex implementation", "High overhead"],
                    correctIndex: 1,
                    explanation: "The convoy effect occurs when many short processes get stuck waiting behind a single long process."
                ),
            ]
        ),
        TutorialModule(
            title: "Round Robin & Priority",
            description: "Explore time-slicing and priority-based scheduling.",
            icon: "arrow.triangle.2.circlepath.circle.fill",
            steps: [
                TutorialStep(
                    title: "Round Robin (RR)",
                    content: "Each process gets a fixed time quantum. When the quantum expires, the process is moved to the back of the ready queue. Like taking turns in a game.\n\nPros: Fair, good response time, no starvation\nCons: Higher context switch overhead, performance depends on quantum size",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    highlightAlgorithm: "rr"
                ),
                TutorialStep(
                    title: "Priority Scheduling",
                    content: "Each process is assigned a priority. The CPU is given to the process with the highest priority. Can be preemptive or non-preemptive.\n\nPros: Important processes run first\nCons: Can cause starvation — solution: aging (gradually increase priority of waiting processes)",
                    icon: "star.circle.fill",
                    highlightAlgorithm: "priority_np"
                ),
            ],
            quiz: [
                QuizQuestion(
                    question: "What happens if the time quantum in Round Robin is too large?",
                    options: ["It becomes like SJF", "It becomes like FCFS", "Processes starve", "CPU utilization drops"],
                    correctIndex: 1,
                    explanation: "With a very large quantum, each process finishes before the quantum expires, making RR behave like FCFS."
                ),
            ]
        ),
    ]

    // MARK: - Mock System Monitor Data
    struct MockSystemProcess: Identifiable {
        let id: UUID = UUID()
        let pid: Int
        let name: String
        let cpuUsage: Double
        let memoryMB: Double
        let threads: Int
        let state: String
        let user: String
    }

    static func generateMockSystemProcesses() -> [MockSystemProcess] {
        return [
            MockSystemProcess(pid: 1, name: "kernel_task", cpuUsage: 3.2, memoryMB: 512, threads: 312, state: "Running", user: "root"),
            MockSystemProcess(pid: 142, name: "WindowServer", cpuUsage: 8.5, memoryMB: 384, threads: 24, state: "Running", user: "root"),
            MockSystemProcess(pid: 345, name: "Finder", cpuUsage: 1.2, memoryMB: 128, threads: 8, state: "Running", user: "rishabh"),
            MockSystemProcess(pid: 512, name: "Safari", cpuUsage: 15.3, memoryMB: 1024, threads: 42, state: "Running", user: "rishabh"),
            MockSystemProcess(pid: 678, name: "Xcode", cpuUsage: 22.1, memoryMB: 2048, threads: 56, state: "Running", user: "rishabh"),
            MockSystemProcess(pid: 789, name: "Terminal", cpuUsage: 0.8, memoryMB: 64, threads: 6, state: "Running", user: "rishabh"),
            MockSystemProcess(pid: 890, name: "Spotlight", cpuUsage: 0.1, memoryMB: 96, threads: 12, state: "Sleeping", user: "root"),
            MockSystemProcess(pid: 921, name: "Mail", cpuUsage: 0.3, memoryMB: 192, threads: 14, state: "Sleeping", user: "rishabh"),
            MockSystemProcess(pid: 1034, name: "Messages", cpuUsage: 0.5, memoryMB: 156, threads: 10, state: "Sleeping", user: "rishabh"),
            MockSystemProcess(pid: 1156, name: "Docker", cpuUsage: 5.7, memoryMB: 768, threads: 28, state: "Running", user: "rishabh"),
            MockSystemProcess(pid: 1289, name: "Slack", cpuUsage: 3.4, memoryMB: 512, threads: 32, state: "Running", user: "rishabh"),
            MockSystemProcess(pid: 1302, name: "VSCode", cpuUsage: 7.8, memoryMB: 640, threads: 38, state: "Running", user: "rishabh"),
        ]
    }
}
