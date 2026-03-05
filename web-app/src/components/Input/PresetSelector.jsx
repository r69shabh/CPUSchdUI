import { BookOpen } from 'lucide-react';
import useSchedulerStore from '../../hooks/useScheduler';
import { PRESETS } from '../../data/presets';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

const PresetSelector = () => {
  const { setProcesses } = useSchedulerStore();

  const handleSelect = (idxValue) => {
    if (idxValue === undefined) return;
    const idx = Number.parseInt(idxValue, 10);
    if (Number.isNaN(idx) || !PRESETS[idx]) return;
    setProcesses(PRESETS[idx].processes);
  };

  return (
    <div className="flex items-center gap-2 rounded-lg border border-border/80 bg-card/55 px-2 py-1.5">
      <BookOpen size={14} className="shrink-0 text-muted-foreground" />
      <Select onValueChange={handleSelect}>
        <SelectTrigger className="h-8 w-[172px] border-0 bg-transparent px-2 shadow-none">
          <SelectValue placeholder="Load Preset..." />
        </SelectTrigger>
        <SelectContent>
          {PRESETS.map((preset, idx) => (
            <SelectItem key={idx} value={String(idx)}>
              {preset.name}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
};

export default PresetSelector;
