import { describe, it, expect } from 'vitest';
import { priority } from '../priority';

describe('Priority Scheduling (Non-preemptive)', () => {
  /*
  Example:
  P1: Arr 0, Burst 4, Prio 2
  P2: Arr 1, Burst 3, Prio 1 (Higher)
  P3: Arr 2, Burst 1, Prio 3
  
  0: P1 arrives. Starts (Non-preemptive). P2 arrives at 1, but P1 continues.
  4: P1 done. Available: P2(Prio 1), P3(Prio 3). P2 runs.
  7: P2 done. P3 runs.
  8: P3 done.
  
  Gantt:
  0-4: P1
  4-7: P2
  7-8: P3
  */

  it('should schedule based on priority non-preemptively', () => {
    const processes = [
      { id: 'P1', arrivalTime: 0, burstTime: 4, priority: 2, color: '#1' },
      { id: 'P2', arrivalTime: 1, burstTime: 3, priority: 1, color: '#2' },
      { id: 'P3', arrivalTime: 2, burstTime: 1, priority: 3, color: '#3' },
    ];

    const { ganttChart } = priority(processes);

    expect(ganttChart.length).toBe(3);
    expect(ganttChart[0]).toMatchObject({ processId: 'P1', start: 0, end: 4 }); // P1 runs fully despite P2 arriving
    expect(ganttChart[1]).toMatchObject({ processId: 'P2', start: 4, end: 7 });
    expect(ganttChart[2]).toMatchObject({ processId: 'P3', start: 7, end: 8 });
  });
});
