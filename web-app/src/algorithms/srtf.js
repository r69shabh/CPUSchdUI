import {
  calculateMetrics,
  calculateSystemMetrics,
} from '../utils/calculations';

/**
 * Shortest Remaining Time First (SRTF) Algorithm
 * Preemptive SJF
 * @param {Array} processes
 * @returns {Object} result
 */
export const srtf = (processes) => {
  const n = processes.length;
  const ganttChart = [];
  const completedProcesses = [];

  // Create a working copy of processes with remaining time
  const activeProcesses = processes.map((p) => ({
    ...p,
    remainingTime: p.burstTime,
    startTime: -1, // First start time
  }));

  let currentTime = 0;
  let completedCount = 0;
  // let currentProcess = null;
  // let lastStartTime = 0;

  // To handle floating point issues or just simplicity, we can simulate unit by unit
  // But event-based is more efficient. For visualization, unit-by-unit is easiest to prevent complex logic bugs,
  // but for performance with large burst times, event-based is better.
  // Given constraints (Burst <= 50, Total Time ~ 200), unit-by-unit is acceptable and robust.

  // However, optimization: jump to next event (arrival or completion of current)
  // Let's stick to unit-by-unit check for simplicity in preemption logic, or optimized loop.
  // Optimization:
  // Find next event time: min(next arrival time, current process completion time)

  // Actually, for SRTF, we need to check at every arrival if preemption happens.
  // And if no arrival, current runs until completion or next arrival.

  const totalBurst = activeProcesses.reduce((sum, p) => sum + p.burstTime, 0);
  // Max time guard
  const maxTime =
    processes.reduce((max, p) => Math.max(max, p.arrivalTime), 0) +
    totalBurst +
    100;

  while (completedCount < n && currentTime < maxTime) {
    // Find candidate processes (arrived and not completed)
    const available = activeProcesses.filter(
      (p) => p.arrivalTime <= currentTime && p.remainingTime > 0
    );

    if (available.length === 0) {
      // Idle
      // Find next arrival
      const pending = activeProcesses.filter(
        (p) => p.remainingTime > 0 && p.arrivalTime > currentTime
      );
      if (pending.length === 0) break; // Should be covered by completedCount check

      const nextArrival = Math.min(...pending.map((p) => p.arrivalTime));

      // If we had a current process, it finished or was invalid, so just gap
      // But if we were idle, we just jump
      currentTime = nextArrival;
      continue;
    }

    // Sort by remaining time, then arrival time
    available.sort((a, b) => {
      if (a.remainingTime === b.remainingTime)
        return a.arrivalTime - b.arrivalTime;
      return a.remainingTime - b.remainingTime;
    });

    const selected = available[0];

    // Determine how long to run
    // Run until next arrival or completion
    // Next arrival that is NOT the current time
    const futureArrivals = activeProcesses.filter(
      (p) => p.arrivalTime > currentTime && p.remainingTime > 0
    );
    let nextEventTime = currentTime + selected.remainingTime;

    if (futureArrivals.length > 0) {
      const nextArrivalTime = Math.min(
        ...futureArrivals.map((p) => p.arrivalTime)
      );
      if (nextArrivalTime < nextEventTime) {
        // We might be preempted at nextArrivalTime
        // But only if the arriving process has strictly less remaining time than (selected.remaining - (nextArr - curr))
        // Actually, in SRTF, we just stop at arrival and re-evaluate.
        nextEventTime = nextArrivalTime;
      }
    }

    const duration = nextEventTime - currentTime;

    // Record start time if first execution
    if (selected.startTime === -1) {
      selected.startTime = currentTime;
    }

    // Add to gantt (merge if same process continues)
    const lastBlock = ganttChart[ganttChart.length - 1];
    if (
      lastBlock &&
      lastBlock.processId === selected.id &&
      lastBlock.end === currentTime
    ) {
      lastBlock.end += duration;
    } else {
      ganttChart.push({
        processId: selected.id,
        start: currentTime,
        end: currentTime + duration,
        color: selected.color,
      });
    }

    // Update state
    selected.remainingTime -= duration;
    currentTime = nextEventTime;

    if (selected.remainingTime <= 0) {
      selected.remainingTime = 0; // clamp
      completedCount++;
      // Calculate metrics
      // We need the original process object for static data, but we have it in selected via spread
      // We can just push selected logic
      const completed = calculateMetrics(
        selected,
        currentTime,
        selected.startTime
      );
      completedProcesses.push(completed);
    }
  }

  const metrics = calculateSystemMetrics(completedProcesses, currentTime);

  // Sort processed by completion or ID? Usually nice to return in order of completion or input
  // Let's sort by ID to match input order for table, or return as is.
  // The table component can sort. The `processes` array here represents "Results".
  // Let's sort result by ID to be consistent with input list
  completedProcesses.sort((a, b) => a.id.localeCompare(b.id));

  return {
    ganttChart,
    processes: completedProcesses,
    metrics,
  };
};
