import { ALGORITHMS } from './constants';

export const ALGORITHM_META = {
  [ALGORITHMS.FCFS]: {
    shortName: 'FCFS',
    label: 'First Come First Served',
    isPreemptive: false,
    needsQuantum: false,
  },
  [ALGORITHMS.SJF]: {
    shortName: 'SJF',
    label: 'Shortest Job First',
    isPreemptive: false,
    needsQuantum: false,
  },
  [ALGORITHMS.SRTF]: {
    shortName: 'SRTF',
    label: 'Shortest Remaining Time First',
    isPreemptive: true,
    needsQuantum: false,
  },
  [ALGORITHMS.RR]: {
    shortName: 'RR',
    label: 'Round Robin',
    isPreemptive: true,
    needsQuantum: true,
  },
  [ALGORITHMS.PRIORITY]: {
    shortName: 'Priority NP',
    label: 'Priority (Non-Preemptive)',
    isPreemptive: false,
    needsQuantum: false,
  },
  [ALGORITHMS.PRIORITY_PREEMPTIVE]: {
    shortName: 'Priority P',
    label: 'Priority (Preemptive)',
    isPreemptive: true,
    needsQuantum: false,
  },
};

export const getAlgorithmMeta = (algorithm) =>
  ALGORITHM_META[algorithm] ?? ALGORITHM_META[ALGORITHMS.FCFS];
