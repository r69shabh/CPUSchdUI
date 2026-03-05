import {
  calculateMetrics,
  calculateSystemMetrics,
} from '../utils/calculations';

/**
 * Shortest Job First (SJF) Algorithm
 * Non-preemptive
 * @param {Array} processes
 * @returns {Object} result
 */
export const sjf = (processes) => {
  const n = processes.length;
  const readyQueue = [];
  const completedProcesses = [];
  const ganttChart = [];

  // Sort by arrival time initially
  const sortedByArrival = [...processes].sort((a, b) => {
    if (a.arrivalTime === b.arrivalTime) return a.id.localeCompare(b.id);
    return a.arrivalTime - b.arrivalTime;
  });

  let currentTime = 0;
  let completedCount = 0;

  // Keep track of which processes are already considered/in ready queue
  // or simply remove from sortedByArrival

  while (completedCount < n) {
    // Add arrived processes to ready queue
    while (
      sortedByArrival.length > 0 &&
      sortedByArrival[0].arrivalTime <= currentTime
    ) {
      readyQueue.push(sortedByArrival.shift());
    }

    if (readyQueue.length === 0) {
      // If nothing in ready queue, jump to next arrival
      if (sortedByArrival.length > 0) {
        currentTime = sortedByArrival[0].arrivalTime;
        continue;
      } else {
        // Should not happen if completedCount < n
        break;
      }
    }

    // Sort ready queue by burst time
    readyQueue.sort((a, b) => {
      if (a.burstTime === b.burstTime) return a.arrivalTime - b.arrivalTime;
      return a.burstTime - b.burstTime;
    });

    const process = readyQueue.shift();

    const startTime = currentTime;
    const endTime = startTime + process.burstTime;

    ganttChart.push({
      processId: process.id,
      start: startTime,
      end: endTime,
      color: process.color,
    });

    const completedProcess = calculateMetrics(process, endTime, startTime);
    completedProcesses.push(completedProcess);

    currentTime = endTime;
    completedCount++;
  }

  const metrics = calculateSystemMetrics(completedProcesses, currentTime);

  return {
    ganttChart,
    processes: completedProcesses,
    metrics,
  };
};
