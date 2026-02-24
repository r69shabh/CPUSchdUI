import {
  calculateMetrics,
  calculateSystemMetrics,
} from '../utils/calculations';

/**
 * Round Robin (RR) Algorithm
 * Preemptive with Time Quantum
 * @param {Array} processes
 * @param {Object} config - { quantum: number }
 * @returns {Object} result
 */
export const roundRobin = (processes, config = { quantum: 2 }) => {
  // const { quantum } = config;
  const n = processes.length;
  const ganttChart = [];
  const completedProcesses = [];

  // Create working copy
  const activeProcesses = processes.map((p) => ({
    ...p,
    remainingTime: p.burstTime,
    startTime: -1,
  }));

  // Sort by arrival time
  // If strict RR, process ID tie break
  const sortedByArrival = [...activeProcesses].sort((a, b) => {
    if (a.arrivalTime === b.arrivalTime) return a.id.localeCompare(b.id);
    return a.arrivalTime - b.arrivalTime;
  });

  const readyQueue = [];
  let currentTime = 0;
  let completedCount = 0;
  let arrivalIndex = 0;

  // Push processes arriving at time 0
  while (
    arrivalIndex < n &&
    sortedByArrival[arrivalIndex].arrivalTime <= currentTime
  ) {
    readyQueue.push(sortedByArrival[arrivalIndex]);
    arrivalIndex++;
  }

  while (completedCount < n) {
    if (readyQueue.length === 0) {
      if (arrivalIndex < n) {
        currentTime = sortedByArrival[arrivalIndex].arrivalTime;
        while (
          arrivalIndex < n &&
          sortedByArrival[arrivalIndex].arrivalTime <= currentTime
        ) {
          readyQueue.push(sortedByArrival[arrivalIndex]);
          arrivalIndex++;
        }
      } else {
        break; // Should not happen
      }
    }

    const currentProcess = readyQueue.shift();

    if (currentProcess.startTime === -1) {
      currentProcess.startTime = currentTime;
    }

    const timeToRun = Math.min(config.quantum, currentProcess.remainingTime);

    ganttChart.push({
      processId: currentProcess.id,
      start: currentTime,
      end: currentTime + timeToRun,
      color: currentProcess.color,
    });

    currentProcess.remainingTime -= timeToRun;
    currentTime += timeToRun;

    // Check for new arrivals during this time slice?
    // Actually, in RR, processes arrive 'while' the CPU is busy?
    // Standard simulation: check arrivals up to current time.
    // Important: Any process arriving EXACTLY at currentTime should be added
    // BEFORE the current process is re-added if it's not done.

    while (
      arrivalIndex < n &&
      sortedByArrival[arrivalIndex].arrivalTime <= currentTime
    ) {
      readyQueue.push(sortedByArrival[arrivalIndex]);
      arrivalIndex++;
    }

    if (currentProcess.remainingTime > 0) {
      readyQueue.push(currentProcess);
    } else {
      completedCount++;
      const completed = calculateMetrics(
        currentProcess,
        currentTime,
        currentProcess.startTime
      );
      completedProcesses.push(completed);
    }
  }

  const metrics = calculateSystemMetrics(completedProcesses, currentTime);

  // Restore order
  completedProcesses.sort((a, b) => a.id.localeCompare(b.id));

  return {
    ganttChart,
    processes: completedProcesses,
    metrics,
  };
};
