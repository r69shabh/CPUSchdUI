import { describe, it, expect } from 'vitest';
import { srtf } from '../srtf';

describe('SRTF Scheduling', () => {
  /*
    Example:
    P1: Arr 0, Burst 8
    P2: Arr 1, Burst 4
    P3: Arr 2, Burst 9
    P4: Arr 3, Burst 5
    
    0: P1 (8) starts.
    1: P2 (4) arrives. P1 rem=7. 4 < 7. Preempt P1. P2 starts.
    2: P3 (9) arrives. P2 rem=3. 3 < 9. Continue P2.
    3: P4 (5) arrives. P2 rem=2. 2 < 5. Continue P2.
    5: P2 finishes. Current: P1(7), P3(9), P4(5). Min is P4(5). P4 starts.
    10: P4 finishes. Current: P1(7), P3(9). Min is P1(7). P1 starts.
    17: P1 finishes. Current: P3(9). P3 starts.
    26: P3 finishes.
    
    Gantt:
    0-1: P1
    1-5: P2
    5-10: P4
    10-17: P1
    17-26: P3
    */

  it('should handle preemption correctly', () => {
    const processes = [
      { id: 'P1', arrivalTime: 0, burstTime: 8, color: '#1' },
      { id: 'P2', arrivalTime: 1, burstTime: 4, color: '#2' },
      { id: 'P3', arrivalTime: 2, burstTime: 9, color: '#3' },
      { id: 'P4', arrivalTime: 3, burstTime: 5, color: '#4' },
    ];

    const { ganttChart, processes: results } = srtf(processes);

    // Check Gantt segments
    expect(ganttChart.length).toBe(5);
    expect(ganttChart[0]).toMatchObject({ processId: 'P1', start: 0, end: 1 });
    expect(ganttChart[1]).toMatchObject({ processId: 'P2', start: 1, end: 5 });
    expect(ganttChart[2]).toMatchObject({ processId: 'P4', start: 5, end: 10 });
    expect(ganttChart[3]).toMatchObject({
      processId: 'P1',
      start: 10,
      end: 17,
    });
    expect(ganttChart[4]).toMatchObject({
      processId: 'P3',
      start: 17,
      end: 26,
    });

    // Check Metrics for P1
    // CT=17, AT=0, TAT=17, WT = TAT - BT = 17 - 8 = 9
    // ResponseTime = 0 - 0 = 0
    const p1 = results.find((p) => p.id === 'P1');
    expect(p1.completionTime).toBe(17);
    expect(p1.waitingTime).toBe(9);
    expect(p1.responseTime).toBe(0);

    // Check Metrics for P2
    // CT=5, AT=1, TAT=4, WT=0, RT=1-1=0
    const p2 = results.find((p) => p.id === 'P2');
    expect(p2.completionTime).toBe(5);
    expect(p2.waitingTime).toBe(0);

    // Check Metrics for P4
    // CT=10, AT=3, TAT=7, WT=2, RT=5-3=2
    const p4 = results.find((p) => p.id === 'P4');
    expect(p4.completionTime).toBe(10);
    expect(p4.waitingTime).toBe(2);
    expect(p4.responseTime).toBe(2);
  });
});
