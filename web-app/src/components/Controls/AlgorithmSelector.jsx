import { ArrowRight, ArrowRightLeft, Cpu, MinusCircle, PlusCircle } from 'lucide-react';
import useSchedulerStore from '../../hooks/useScheduler';
import { ALGORITHMS } from '../../utils/constants';
import { getAlgorithmMeta } from '../../utils/algorithmMeta';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';

const AlgorithmSelector = () => {
  const { selectedAlgorithm, setAlgorithm, quantum, setQuantum } =
    useSchedulerStore();
  const selectedMeta = getAlgorithmMeta(selectedAlgorithm);

  const algorithms = [
    { value: ALGORITHMS.FCFS, label: 'First Come First Served', short: 'FCFS' },
    { value: ALGORITHMS.SJF, label: 'Shortest Job First', short: 'SJF' },
    {
      value: ALGORITHMS.SRTF,
      label: 'Shortest Remaining Time First',
      short: 'SRTF',
    },
    { value: ALGORITHMS.RR, label: 'Round Robin', short: 'RR' },
    {
      value: ALGORITHMS.PRIORITY,
      label: 'Priority (Non-Preemptive)',
      short: 'Priority NP',
    },
    {
      value: ALGORITHMS.PRIORITY_PREEMPTIVE,
      label: 'Priority (Preemptive)',
      short: 'Priority P',
    },
  ];

  return (
    <div className="flex flex-wrap items-center gap-3">
      <div className="flex items-center gap-2 rounded-lg border border-border/80 bg-card/55 px-2 py-1.5">
        <Cpu className="h-4 w-4 text-primary" />
        <Select value={selectedAlgorithm} onValueChange={setAlgorithm}>
          <SelectTrigger className="h-8 min-w-[180px] border-0 bg-transparent px-2 shadow-none">
            <SelectValue placeholder="Select algorithm" />
          </SelectTrigger>
          <SelectContent>
            {algorithms.map((algo) => (
              <SelectItem key={algo.value} value={algo.value}>
                <span className="flex items-center gap-2">
                  <span className="font-medium">{algo.short}</span>
                  <span className="text-muted-foreground">{algo.label}</span>
                </span>
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {selectedMeta.needsQuantum && (
        <div className="animate-in fade-in slide-in-from-left-2 flex items-center gap-1 rounded-lg border border-border/80 bg-card/55 px-2 py-1.5 duration-200">
          <Label className="text-xs text-muted-foreground">Quantum</Label>
          <Button
            type="button"
            variant="ghost"
            size="icon"
            className="h-7 w-7"
            onClick={() => setQuantum(Math.max(1, quantum - 1))}
            aria-label="Decrease quantum"
          >
            <MinusCircle className="h-4 w-4" />
          </Button>
          <Input
            type="number"
            min="1"
            max="20"
            value={quantum}
            onChange={(e) => setQuantum(parseInt(e.target.value) || 1)}
            className="h-7 w-14 border-0 bg-transparent px-1 text-center font-mono shadow-none"
          />
          <Button
            type="button"
            variant="ghost"
            size="icon"
            className="h-7 w-7"
            onClick={() => setQuantum(Math.min(20, quantum + 1))}
            aria-label="Increase quantum"
          >
            <PlusCircle className="h-4 w-4" />
          </Button>
        </div>
      )}

      <div className="flex items-center gap-1 rounded-full border border-border/80 bg-card/55 px-3 py-1.5 text-xs text-muted-foreground">
        {selectedMeta.isPreemptive ? (
          <ArrowRightLeft className="h-3.5 w-3.5" />
        ) : (
          <ArrowRight className="h-3.5 w-3.5" />
        )}
        <span>
          {selectedMeta.isPreemptive ? 'Preemptive' : 'Non-Preemptive'}
        </span>
      </div>
    </div>
  );
};

export default AlgorithmSelector;
