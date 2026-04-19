import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import * as algorithms from '../algorithms';
import { ALGORITHMS, DEFAULT_QUANTUM } from '../utils/constants';

const useSchedulerStore = create(
  persist(
    (set, get) => ({
      processes: [
        {
          id: 'P1',
          arrivalTime: 0,
          burstTime: 4,
          priority: 1,
          color: '#4A90E2',
        },
        {
          id: 'P2',
          arrivalTime: 1,
          burstTime: 3,
          priority: 2,
          color: '#E94B3C',
        },
        {
          id: 'P3',
          arrivalTime: 2,
          burstTime: 1,
          priority: 3,
          color: '#50C878',
        },
      ],
      selectedAlgorithm: ALGORITHMS.FCFS,
      quantum: DEFAULT_QUANTUM,
      results: null,

      setProcesses: (processes) => {
        set({ processes, results: null });
      },

      addProcess: (process) => {
        set((state) => ({
          processes: [...state.processes, process],
          results: null,
        }));
      },

      removeProcess: (processId) => {
        set((state) => ({
          processes: state.processes.filter((p) => p.id !== processId),
          results: null,
        }));
      },

      updateProcess: (processId, field, value) => {
        set((state) => ({
          processes: state.processes.map((p) =>
            p.id === processId ? { ...p, [field]: value } : p
          ),
          results: null,
        }));
      },

      setAlgorithm: (algorithm) => {
        set({ selectedAlgorithm: algorithm, results: null });
      },

      setQuantum: (quantum) => {
        set({ quantum, results: null });
      },

      runScheduler: () => {
        const { processes, selectedAlgorithm, quantum } = get();
        if (processes.length === 0) {
          set({ results: null });
          return;
        }

        let result;
        const config = { quantum };

        try {
          switch (selectedAlgorithm) {
            case ALGORITHMS.FCFS:
              result = algorithms.fcfs(processes);
              break;
            case ALGORITHMS.SJF:
              result = algorithms.sjf(processes);
              break;
            case ALGORITHMS.SRTF:
              result = algorithms.srtf(processes);
              break;
            case ALGORITHMS.RR:
              result = algorithms.roundRobin(processes, config);
              break;
            case ALGORITHMS.PRIORITY:
              result = algorithms.priority(processes);
              break;
            case ALGORITHMS.PRIORITY_PREEMPTIVE:
              result = algorithms.priorityPreemptive(processes);
              break;
            default:
              result = algorithms.fcfs(processes);
          }
          set({ results: result });
        } catch (error) {
          console.error('Scheduler Error:', error);
          set({ results: null });
        }
      },
    }),
    {
      name: 'scheduler-storage', // name of the item in the storage (must be unique)
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        processes: state.processes,
        selectedAlgorithm: state.selectedAlgorithm,
        quantum: state.quantum,
      }), // only persist these fields
      onRehydrateStorage: () => (state) => {
        if (state) state.results = null;
      },
    }
  )
);

export default useSchedulerStore;
