import {
  calculateMetrics,
  calculateSystemMetrics,
} from '../utils/calculations';

/**
 * Priority Algorithm (Non-preemptive)
 * Lower number = Higher priority
 * @param {Array} processes
 * @returns {Object} result
 */
export const priority = (processes) => {
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

  while (completedCount < n) {
    // Add arrived processes to ready queue
    while (
      sortedByArrival.length > 0 &&
      sortedByArrival[0].arrivalTime <= currentTime
    ) {
      readyQueue.push(sortedByArrival.shift());
    }

    if (readyQueue.length === 0) {
      if (sortedByArrival.length > 0) {
        currentTime = sortedByArrival[0].arrivalTime;
        continue;
      } else {
        break;
      }
    }

    // Sort ready queue by Priority (asc) -> Arrival (asc)
    readyQueue.sort((a, b) => {
      if (a.priority === b.priority) return a.arrivalTime - b.arrivalTime;
      return a.priority - b.priority;
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
