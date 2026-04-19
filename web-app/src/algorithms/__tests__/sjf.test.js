import { describe, it, expect } from 'vitest';
import { sjf } from '../sjf';

describe('SJF Scheduling', () => {
  const processes = [
    { id: 'P1', arrivalTime: 0, burstTime: 6, color: '#000' },
    { id: 'P2', arrivalTime: 0, burstTime: 8, color: '#000' },
    { id: 'P3', arrivalTime: 0, burstTime: 7, color: '#000' },
    { id: 'P4', arrivalTime: 0, burstTime: 3, color: '#000' },
  ];
  // Arrival all 0. Order should be P4(3), P1(6), P3(7), P2(8)

  it('should schedule shortest job first when all arrive at 0', () => {
    const { ganttChart } = sjf(processes);

    expect(ganttChart[0].processId).toBe('P4');
    expect(ganttChart[1].processId).toBe('P1');
    expect(ganttChart[2].processId).toBe('P3');
    expect(ganttChart[3].processId).toBe('P2');
  });

  it('should handle different arrival times', () => {
    const proc = [
      { id: 'P1', arrivalTime: 0, burstTime: 8, color: '#000' },
      { id: 'P2', arrivalTime: 1, burstTime: 4, color: '#000' },
      { id: 'P3', arrivalTime: 2, burstTime: 9, color: '#000' },
      { id: 'P4', arrivalTime: 3, burstTime: 5, color: '#000' },
    ];
    // 0: P1 arrives. Valid for 0-8.
    // 8: P1 Done. Ready: P2(4), P3(9), P4(5). Sorted: P2, P4, P3.
    // P2: 8-12.
    // P4: 12-17.
    // P3: 17-26.

    const { ganttChart } = sjf(proc);

    expect(ganttChart[0].processId).toBe('P1');
    expect(ganttChart[1].processId).toBe('P2');
    expect(ganttChart[2].processId).toBe('P4');
    expect(ganttChart[3].processId).toBe('P3');
  });
});
