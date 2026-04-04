import { Clock, Target, Zap, Layers } from 'lucide-react';
import { ALGORITHMS } from '../utils/constants';

export const explanations = {
  [ALGORITHMS.FCFS]: {
    id: ALGORITHMS.FCFS,
    title: 'First Come First Served (FCFS)',
    shortDesc:
      'Simplest scheduling algorithm. Processes are executed in the order they arrive in the ready queue.',
    description:
      'First-Come, First-Served (FCFS) is the simplest scheduling algorithm. Processes are dispatched according to their arrival time on the ready queue. Once a process gets the CPU, it runs to completion (Non-preemptive). It is implemented using a FIFO (First In, First Out) queue.',
    pros: [
      'Simple and easy to understand',
      'Fair in terms of arrival order',
      'Easy to implement',
      'No starvation - every process gets CPU time',
    ],
    cons: [
      'Convoy effect (short processes wait for long ones)',
      'High average waiting time',
      'Not suitable for time-sharing systems',
    ],
    realWorld: 'Batch processing systems, print queue management',
    icon: Clock,
    complexity: 'Low',
    preemptive: 'No',
  },
  [ALGORITHMS.SJF]: {
    id: ALGORITHMS.SJF,
    title: 'Shortest Job First (SJF)',
    shortDesc:
      'Selects the process with the smallest burst time to execute next.',
    description:
      'Shortest Job First (SJF) selects the process with the smallest burst time from the queue. It provides the minimum average waiting time (optimal). It requires knowledge of future CPU burst times, which are often estimated using techniques like Exponential Averaging.',
    pros: [
      'Optimal Algorithm (minimum average waiting time)',
      'Maximum throughput for batch systems',
      'Efficient for known job times',
    ],
    cons: [
      'Starvation of long processes is possible',
      'Difficult to know exact burst times in advance',
      'Requires burst time estimation',
    ],
    realWorld:
      'Batch systems where job times are known, background task processing',
    icon: Target,
    complexity: 'Medium',
    preemptive: 'No',
  },
  [ALGORITHMS.SRTF]: {
    id: ALGORITHMS.SRTF,
    title: 'Shortest Remaining Time First',
    shortDesc:
      'Preemptive version of SJF. Process with shortest remaining burst time runs next.',
    description:
      'Shortest Remaining Time First (SRTF) is the preemptive version of SJF. At each scheduling point, it selects the process with the shortest remaining burst time. If a new process arrives with a shorter burst time than the remaining time of the current process, the CPU is preempted.',
    pros: [
      'Optimal average waiting time (among preemptive)',
      'Responsive to short jobs',
      'Low turnaround time',
    ],
    cons: [
      'High context switching overhead',
      'Starvation of long processes',
      'Complex to implement & requires prediction',
    ],
    realWorld:
      'Scientific computing with job estimation, cloud computing resource allocation',
    icon: Zap,
    complexity: 'High',
    preemptive: 'Yes',
  },
  [ALGORITHMS.RR]: {
    id: ALGORITHMS.RR,
    title: 'Round Robin (RR)',
    shortDesc: 'Each process gets a small unit of CPU time (time quantum).',
    description:
      'Round Robin (RR) is designed specifically for time-sharing systems. Each process gets a small unit of CPU time (time quantum), typically 10-100ms. After the quantum expires, the process is preempted and added to the end of the ready queue. Implementation uses a circular queue.',
    pros: [
      'Fair - no starvation, equal CPU share',
      'Good response time for interactive systems',
      'Predictable waiting time',
    ],
    cons: [
      'Performance depends heavily on quantum size',
      'Higher turnaround time than SJF',
      'Context switch overhead',
    ],
    realWorld:
      'Time-sharing systems, Windows/Linux desktop scheduling, interactive applications',
    icon: Layers,
    complexity: 'Medium',
    preemptive: 'Yes',
  },
  [ALGORITHMS.PRIORITY]: {
    id: ALGORITHMS.PRIORITY,
    title: 'Priority (Non-preemptive)',
    shortDesc: 'CPU allocated to the highest priority process.',
    description:
      'In Priority Scheduling, each process is assigned a priority number. The CPU is allocated to the process with the highest priority (in this simulation, lower number = higher priority). Ties are typically broken by FCFS.',
    pros: [
      'Handles relative importance of tasks',
      'Good for real-time systems',
      'Flexible policies (internal vs external priority)',
    ],
    cons: [
      'Indefinite blocking (starvation) of low priority processes',
      'Priority Inversion problem',
      'Requires aging to prevent starvation',
    ],
    realWorld:
      'Real-time systems, OS kernel processes, I/O-bound vs CPU-bound differentiation',
    icon: Target,
    complexity: 'Low',
    preemptive: 'No',
  },
  [ALGORITHMS.PRIORITY_PREEMPTIVE]: {
    id: ALGORITHMS.PRIORITY_PREEMPTIVE,
    title: 'Priority (Preemptive)',
    shortDesc:
      'Highest priority process always executes, preempting lower priority ones.',
    description:
      'Extension of priority scheduling. When a new process arrives with higher priority than the currently running process, the CPU is preempted and assigned to the new process. This ensures the highest priority task runs immediately.',
    pros: [
      'More Responsive to high priority tasks',
      'Suitable for hard real-time systems',
      'High priority tasks run immediately',
    ],
    cons: [
      'Higher overhead (context switches)',
      'Starvation risk is severe',
      'Complex to verify',
    ],
    realWorld:
      'OS interrupt handling, real-time embedded systems, multimedia applications',
    icon: Zap,
    complexity: 'High',
    preemptive: 'Yes',
  },
};
