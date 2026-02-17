import {
  calculateMetrics,
  calculateSystemMetrics,
} from '../utils/calculations';

/**
 * Priority Algorithm (Preemptive)
 * Lower number = Higher priority
 * @param {Array} processes
 * @returns {Object} result
 */
export const priorityPreemptive = (processes) => {
  const n = processes.length;
  const ganttChart = [];
  const completedProcesses = [];

  const activeProcesses = processes.map((p) => ({
    ...p,
    remainingTime: p.burstTime,
    startTime: -1,
  }));

  const totalBurst = activeProcesses.reduce((sum, p) => sum + p.burstTime, 0);
  const maxTime =
    processes.reduce((max, p) => Math.max(max, p.arrivalTime), 0) +
    totalBurst +
    100;

  let currentTime = 0;
  let completedCount = 0;

  while (completedCount < n && currentTime < maxTime) {
    // Find available processes
    const available = activeProcesses.filter(
      (p) => p.arrivalTime <= currentTime && p.remainingTime > 0
    );

    if (available.length === 0) {
      // Idle
      const pending = activeProcesses.filter(
        (p) => p.remainingTime > 0 && p.arrivalTime > currentTime
      );
      if (pending.length === 0) break;

      const nextArrival = Math.min(...pending.map((p) => p.arrivalTime));
      currentTime = nextArrival;
      continue;
    }

    // Sort by Priority (asc) -> Arrival (asc)
    available.sort((a, b) => {
      if (a.priority === b.priority) return a.arrivalTime - b.arrivalTime;
      return a.priority - b.priority;
    });

    const selected = available[0];

    // Determine duration: Run until next arrival that could preempt
    // i.e., arrival with priority < selected.priority
    // OR until selected finishes.

    const higherPriorityArrivals = activeProcesses.filter(
      (p) =>
        p.arrivalTime > currentTime &&
        p.remainingTime > 0 &&
        p.priority < selected.priority
    );

    let nextEventTime = currentTime + selected.remainingTime;

    if (higherPriorityArrivals.length > 0) {
      const nextPreemptionTime = Math.min(
        ...higherPriorityArrivals.map((p) => p.arrivalTime)
      );
      if (nextPreemptionTime < nextEventTime) {
        nextEventTime = nextPreemptionTime;
      }
    }

    // Also consider ANY arrival? Standards vary.
    // If strict preemptive priority: only preempt if strictly higher priority arrives.
    // If equal priority arrives? Usually FCFS for equal, so do not preempt.
    // So logic above (p.priority < selected.priority) holds.

    const duration = nextEventTime - currentTime;

    if (selected.startTime === -1) {
      selected.startTime = currentTime;
    }

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

    selected.remainingTime -= duration;
    currentTime = nextEventTime;

    if (selected.remainingTime <= 0) {
      selected.remainingTime = 0;
      completedCount++;
      const completed = calculateMetrics(
        selected,
        currentTime,
        selected.startTime
      );
      completedProcesses.push(completed);
    }
  }

  const metrics = calculateSystemMetrics(completedProcesses, currentTime);
  completedProcesses.sort((a, b) => a.id.localeCompare(b.id));

  return {
    ganttChart,
    processes: completedProcesses,
    metrics,
  };
};
