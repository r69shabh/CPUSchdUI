import { getProcessColor } from '../utils/constants';

export const PRESETS = [
  {
    name: 'Simple Example',
    description: '3 processes arrival at 0, 1, 2',
    processes: [
      {
        id: 'P1',
        arrivalTime: 0,
        burstTime: 5,
        priority: 2,
        color: getProcessColor(0),
      },
      {
        id: 'P2',
        arrivalTime: 1,
        burstTime: 3,
        priority: 1,
        color: getProcessColor(1),
      },
      {
        id: 'P3',
        arrivalTime: 2,
        burstTime: 8,
        priority: 3,
        color: getProcessColor(2),
      },
    ],
  },
  {
    name: 'Convoy Effect (FCFS Weakness)',
    description: 'Long process first delays others',
    processes: [
      {
        id: 'P1',
        arrivalTime: 0,
        burstTime: 15,
        priority: 2,
        color: getProcessColor(0),
      },
      {
        id: 'P2',
        arrivalTime: 1,
        burstTime: 2,
        priority: 1,
        color: getProcessColor(1),
      },
      {
        id: 'P3',
        arrivalTime: 2,
        burstTime: 2,
        priority: 3,
        color: getProcessColor(2),
      },
    ],
  },
  {
    name: 'SJF/SRTF Demo',
    description: 'Processes with varied burst times',
    processes: [
      {
        id: 'P1',
        arrivalTime: 0,
        burstTime: 8,
        priority: 1,
        color: getProcessColor(0),
      },
      {
        id: 'P2',
        arrivalTime: 1,
        burstTime: 4,
        priority: 1,
        color: getProcessColor(1),
      },
      {
        id: 'P3',
        arrivalTime: 2,
        burstTime: 9,
        priority: 1,
        color: getProcessColor(2),
      },
      {
        id: 'P4',
        arrivalTime: 3,
        burstTime: 5,
        priority: 1,
        color: getProcessColor(3),
      },
    ],
  },
  {
    name: 'Priority Scheduling',
    description: 'Processes with different priorities',
    processes: [
      {
        id: 'P1',
        arrivalTime: 0,
        burstTime: 10,
        priority: 3,
        color: getProcessColor(0),
      },
      {
        id: 'P2',
        arrivalTime: 1,
        burstTime: 1,
        priority: 1,
        color: getProcessColor(1),
      },
      {
        id: 'P3',
        arrivalTime: 2,
        burstTime: 2,
        priority: 4,
        color: getProcessColor(2),
      },
      {
        id: 'P4',
        arrivalTime: 3,
        burstTime: 1,
        priority: 5,
        color: getProcessColor(3),
      },
      {
        id: 'P5',
        arrivalTime: 4,
        burstTime: 5,
        priority: 2,
        color: getProcessColor(4),
      },
    ],
  },
];
