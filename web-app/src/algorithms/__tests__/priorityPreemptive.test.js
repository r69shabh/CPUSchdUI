import { describe, it, expect } from 'vitest';
import { priorityPreemptive } from '../priorityPreemptive';

describe('Priority Scheduling (Preemptive)', () => {
  /*
    Example:
    P1: Arr 0, Burst 4, Prio 2
    P2: Arr 1, Burst 3, Prio 1
    
    0: P1 arrives. P1 runs.
    1: P2 arrives (Prio 1 < 2). Preempt P1 (Rem=3). P2 runs.
    4: P2 done. P1 runs.
    7: P1 done.
    
    Gantt:
    0-1: P1
    1-4: P2
    4-7: P1
    */

  it('should preempt lower priority process', () => {
    const processes = [
      { id: 'P1', arrivalTime: 0, burstTime: 4, priority: 2, color: '#1' },
      { id: 'P2', arrivalTime: 1, burstTime: 3, priority: 1, color: '#2' },
    ];

    const { ganttChart } = priorityPreemptive(processes);

    expect(ganttChart.length).toBe(3);
    expect(ganttChart[0]).toMatchObject({ processId: 'P1', start: 0, end: 1 });
    expect(ganttChart[1]).toMatchObject({ processId: 'P2', start: 1, end: 4 });
    expect(ganttChart[2]).toMatchObject({ processId: 'P1', start: 4, end: 7 });
  });
});
