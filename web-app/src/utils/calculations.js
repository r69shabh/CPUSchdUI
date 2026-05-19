export const calculateMetrics = (process, completionTime, firstStartTime) => {
  const turnaroundTime = completionTime - process.arrivalTime;
  const waitingTime = turnaroundTime - process.burstTime;
  const responseTime = firstStartTime - process.arrivalTime;

  return {
    ...process,
    completionTime,
    turnaroundTime,
    waitingTime,
    responseTime,
  };
};

export const calculateAverageMetrics = (processes) => {
  if (!processes.length)
    return { avgTurnaroundTime: 0, avgWaitingTime: 0, avgResponseTime: 0 };

  const totalTAT = processes.reduce((acc, p) => acc + p.turnaroundTime, 0);
  const totalWT = processes.reduce((acc, p) => acc + p.waitingTime, 0);
  const totalRT = processes.reduce((acc, p) => acc + p.responseTime, 0);

  return {
    avgTurnaroundTime: totalTAT / processes.length,
    avgWaitingTime: totalWT / processes.length,
    avgResponseTime: totalRT / processes.length,
  };
};

export const calculateSystemMetrics = (processes, totalTime) => {
  const averages = calculateAverageMetrics(processes);
  const totalBurstTime = processes.reduce((acc, p) => acc + p.burstTime, 0);
  const cpuUtilization = totalTime > 0 ? (totalBurstTime / totalTime) * 100 : 0;
  const throughput = totalTime > 0 ? processes.length / totalTime : 0;

  return {
    ...averages,
    cpuUtilization,
    throughput,
  };
};

export const calculateContextSwitches = (timeline = []) => {
  if (!timeline || timeline.length < 2) return 0;

  return timeline.slice(1).reduce((switches, segment, index) => {
    const previous = timeline[index];
    return previous.processId === segment.processId ? switches : switches + 1;
  }, 0);
};
