import { describe, it, expect } from 'vitest';
import { fcfs } from '../fcfs';

describe('FCFS Scheduling', () => {
  const processes = [
    { id: 'P1', arrivalTime: 0, burstTime: 5, color: '#000' },
    { id: 'P2', arrivalTime: 1, burstTime: 3, color: '#000' },
    { id: 'P3', arrivalTime: 2, burstTime: 8, color: '#000' },
  ];

  it('should schedule processes correctly based on arrival time', () => {
    const { ganttChart, processes: results } = fcfs(processes);

    expect(ganttChart).toHaveLength(3);
    expect(ganttChart[0].processId).toBe('P1');
    expect(ganttChart[0].start).toBe(0);
    expect(ganttChart[0].end).toBe(5);

    expect(ganttChart[1].processId).toBe('P2');
    expect(ganttChart[1].start).toBe(5);
    expect(ganttChart[1].end).toBe(8); // 5 + 3

    expect(ganttChart[2].processId).toBe('P3');
    expect(ganttChart[2].start).toBe(8);
    expect(ganttChart[2].end).toBe(16); // 8 + 8

    expect(results).toHaveLength(3);
    // P1: AT=0, BT=5, CT=5, TAT=5, WT=0
    expect(results[0].turnaroundTime).toBe(5);
    expect(results[0].waitingTime).toBe(0);

    // P2: AT=1, BT=3, Start=5, End=8, TAT=7, WT=4
    expect(results[1].turnaroundTime).toBe(7);
    expect(results[1].waitingTime).toBe(4);
  });

  it('should handle idle time', () => {
    const proc = [
      { id: 'P1', arrivalTime: 0, burstTime: 2, color: '#000' },
      { id: 'P2', arrivalTime: 4, burstTime: 2, color: '#000' },
    ];
    const { ganttChart } = fcfs(proc);

    expect(ganttChart[0].end).toBe(2);
    expect(ganttChart[1].start).toBe(4); // Gap 2-4
  });
});
