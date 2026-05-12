import {
  calculateMetrics,
  calculateSystemMetrics,
} from '../utils/calculations';

/**
 * First Come First Serve (FCFS) Algorithm
 * Non-preemptive
 * @param {Array} processes
 * @returns {Object} result
 */
export const fcfs = (processes) => {
  // Sort by arrival time
  // If arrival times are equal, keep original order (stable sort mostly, but relying on stability of sort or ID)
  // For strict FCFS, pure arrival time sort is standard.
  const sortedProcesses = [...processes].sort((a, b) => {
    if (a.arrivalTime === b.arrivalTime) {
      // Tie-breaker: process ID or original index could be used, here assuming stable sort or ID
      return 0;
    }
    return a.arrivalTime - b.arrivalTime;
  });

  let currentTime = 0;
  const ganttChart = [];
  const completedProcesses = [];

  sortedProcesses.forEach((process) => {
    // If CPU is idle
    if (currentTime < process.arrivalTime) {
      // You might want to represent idle time in ganttChart or just jump
      currentTime = process.arrivalTime;
    }

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
  });

  const metrics = calculateSystemMetrics(completedProcesses, currentTime);

  return {
    ganttChart,
    processes: completedProcesses,
    metrics,
  };
};
