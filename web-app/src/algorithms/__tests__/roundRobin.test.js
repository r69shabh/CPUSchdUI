import { describe, it, expect } from 'vitest';
import { roundRobin } from '../roundRobin';

describe('Round Robin Scheduling', () => {
  /*
  Example: 
  P1: Arr 0, Burst 5
  P2: Arr 1, Burst 3
  P3: Arr 2, Burst 1
  Quantum = 2
  
  0: Q=[P1]. P1 runs 0-2. Rem: P1(3). Time=2.
     Arrivals at <=2: P2(Arr 1), P3(Arr 2). 
     Q=[P2, P3]. Then P1 added. Q=[P2, P3, P1].
  2: Pop P2. Runs 2-4. Rem: P2(1). Time=4.
     Arrivals: None.
     Q=[P3, P1]. Add P2. Q=[P3, P1, P2].
  4: Pop P3. Runs 4-5. Rem: P3(0). Done. Time=5.
     Q=[P1, P2].
  5: Pop P1. Runs 5-7. Rem: P1(1). Time=7.
     Q=[P2]. Add P1. Q=[P2, P1].
  7: Pop P2. Runs 7-8. Rem: P2(0). Done. Time=8.
     Q=[P1].
  8: Pop P1. Runs 8-9. Rem: P1(0). Done. Time=9.
  
  Gantt:
  0-2: P1
  2-4: P2
  4-5: P3
  5-7: P1
  7-8: P2
  8-9: P1
  */

  it('should handle round robin logic correctly', () => {
    const processes = [
      { id: 'P1', arrivalTime: 0, burstTime: 5, color: '#1' },
      { id: 'P2', arrivalTime: 1, burstTime: 3, color: '#2' },
      { id: 'P3', arrivalTime: 2, burstTime: 1, color: '#3' },
    ];

    const { ganttChart, processes: results } = roundRobin(processes, {
      quantum: 2,
    });

    // Segments
    expect(ganttChart.length).toBe(6);
    expect(ganttChart[0]).toMatchObject({ processId: 'P1', start: 0, end: 2 });
    expect(ganttChart[1]).toMatchObject({ processId: 'P2', start: 2, end: 4 });
    expect(ganttChart[2]).toMatchObject({ processId: 'P3', start: 4, end: 5 });
    expect(ganttChart[3]).toMatchObject({ processId: 'P1', start: 5, end: 7 });
    expect(ganttChart[4]).toMatchObject({ processId: 'P2', start: 7, end: 8 });
    expect(ganttChart[5]).toMatchObject({ processId: 'P1', start: 8, end: 9 });

    // P3 Stats: CT=5, AT=2, TAT=3, WT=2
    const p3 = results.find((p) => p.id === 'P3');
    expect(p3.completionTime).toBe(5);
    expect(p3.waitingTime).toBe(2);

    // P2 Stats: CT=8, AT=1, TAT=7, WT=4
    const p2 = results.find((p) => p.id === 'P2');
    expect(p2.completionTime).toBe(8);
    expect(p2.waitingTime).toBe(4);

    // P1 Stats: CT=9, AT=0, TAT=9, WT=4
    const p1 = results.find((p) => p.id === 'P1');
    expect(p1.completionTime).toBe(9);
    expect(p1.waitingTime).toBe(4);
  });
});
