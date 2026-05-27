export const ALGORITHMS = {
  FCFS: 'fcfs',
  SJF: 'sjf',
  SRTF: 'srtf',
  RR: 'roundRobin',
  PRIORITY: 'priority',
  PRIORITY_PREEMPTIVE: 'priorityPreemptive',
};

export const PROCESS_COLORS = [
  '#4A90E2',
  '#E94B3C',
  '#50C878',
  '#F39C12',
  '#9B59B6',
  '#1ABC9C',
  '#E67E22',
  '#3498DB',
  '#16A085',
  '#C0392B',
];

export const DEFAULT_QUANTUM = 4;
export const MAX_PROCESSES = 20;
export const MIN_BURST_TIME = 1;
export const MAX_BURST_TIME = 20;

export const getProcessColor = (index) => {
  return PROCESS_COLORS[index % PROCESS_COLORS.length];
};
