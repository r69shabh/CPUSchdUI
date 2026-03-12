import { useMemo, useState } from 'react';
import {
  Clock3,
  Dice5,
  FolderOpen,
  ListOrdered,
  Plus,
  Star,
  Trash2,
  Gauge,
  Inbox,
  X,
} from 'lucide-react';
import useSchedulerStore from '../../hooks/useScheduler';
import {
  getProcessColor,
  MAX_BURST_TIME,
  MAX_PROCESSES,
} from '../../utils/constants';
import { PRESETS } from '../../data/presets';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';

const seedFromPreset = (preset) =>
  preset.processes.map((process, idx) => ({
    ...process,
    id: `P${idx + 1}`,
    color: getProcessColor(idx),
  }));

const ProcessInput = () => {
  const { processes, addProcess, removeProcess, setProcesses } = useSchedulerStore();
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [isScenarioOpen, setIsScenarioOpen] = useState(false);
  const [selectedPreset, setSelectedPreset] = useState(null);
  const [draft, setDraft] = useState({
    arrivalTime: 0,
    burstTime: 5,
    priority: 1,
  });

  const processCountLabel = `${processes.length} process${processes.length === 1 ? '' : 'es'}`;
  const totalBurst = useMemo(
    () => processes.reduce((total, process) => total + process.burstTime, 0),
    [processes]
  );

  const createProcess = () => {
    if (processes.length >= MAX_PROCESSES) return;

    const nextId = processes.length + 1;
    addProcess({
      id: `P${nextId}`,
      arrivalTime: Math.max(0, draft.arrivalTime),
      burstTime: Math.min(MAX_BURST_TIME, Math.max(1, draft.burstTime)),
      priority: Math.max(1, draft.priority),
      color: getProcessColor(nextId - 1),
    });

    setIsAddOpen(false);
  };

  const generateRandomProcesses = () => {
    const count = Math.floor(Math.random() * 5) + 4;
    const random = Array.from({ length: count }, (_, idx) => ({
      id: `P${idx + 1}`,
      arrivalTime: Math.floor(Math.random() * 11),
      burstTime: Math.floor(Math.random() * 14) + 2,
      priority: Math.floor(Math.random() * 10) + 1,
      color: getProcessColor(idx),
    })).sort((a, b) => a.arrivalTime - b.arrivalTime);

    setProcesses(random);
  };

  const loadSelectedScenario = () => {
    if (selectedPreset == null) return;
    setProcesses(seedFromPreset(PRESETS[selectedPreset]));
    setIsScenarioOpen(false);
  };

  return (
    <div className="flex h-full min-h-0 flex-col bg-card/70">
      <div className="flex items-center gap-2 border-b border-border/70 px-4 py-3">
        <ListOrdered className="h-4 w-4 text-primary" />
        <h2 className="text-sm font-semibold">Processes</h2>
        <div className="ml-auto">
          <Popover>
            <PopoverTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8 text-primary"
                aria-label="Open process actions"
              >
                <Plus className="h-5 w-5" />
              </Button>
            </PopoverTrigger>
            <PopoverContent align="end" className="w-56 p-2">
              <div className="space-y-1">
                <Button
                  variant="ghost"
                  className="h-8 w-full justify-start gap-2 px-2"
                  onClick={() => setIsAddOpen(true)}
                >
                  <Plus className="h-4 w-4" />
                  Add Manually
                </Button>
                <Button
                  variant="ghost"
                  className="h-8 w-full justify-start gap-2 px-2"
                  onClick={() => setIsScenarioOpen(true)}
                >
                  <FolderOpen className="h-4 w-4" />
                  Load Scenario
                </Button>
                <Button
                  variant="ghost"
                  className="h-8 w-full justify-start gap-2 px-2"
                  onClick={generateRandomProcesses}
                >
                  <Dice5 className="h-4 w-4" />
                  Generate Random
                </Button>
              </div>
            </PopoverContent>
          </Popover>
        </div>
      </div>

      {processes.length > 0 && (
        <div className="flex items-center justify-between border-b border-border/60 bg-muted/35 px-4 py-2 text-xs text-muted-foreground">
          <span>{processCountLabel}</span>
          <span>Total burst: {totalBurst}</span>
        </div>
      )}

      <div className="custom-scrollbar min-h-0 flex-1 overflow-y-auto">
        {processes.length === 0 ? (
          <div className="flex h-full flex-col items-center justify-center gap-4 px-6 text-center">
            <Inbox className="h-11 w-11 text-muted-foreground/60" />
            <div className="space-y-1">
              <p className="text-lg font-semibold">No Processes</p>
              <p className="text-sm text-muted-foreground">
                Click + to add processes
                <br />
                or load a scenario
              </p>
            </div>
            <div className="flex items-center gap-2">
              <Button variant="outline" size="sm" onClick={() => setIsAddOpen(true)}>
                Add Process
              </Button>
              <Button size="sm" onClick={generateRandomProcesses}>
                Random
              </Button>
            </div>
          </div>
        ) : (
          <div className="space-y-2 p-3">
            {processes.map((process) => (
              <article
                key={process.id}
                className="group relative overflow-hidden rounded-lg border border-border/70 bg-card/75 px-3 py-2.5 transition-colors hover:border-primary/35"
              >
                <span
                  className="absolute inset-y-0 left-0 w-1"
                  style={{ backgroundColor: process.color }}
                />
                <div className="ml-2 flex items-start justify-between gap-2">
                  <div className="space-y-2">
                    <span className="inline-block rounded bg-muted px-2 py-0.5 text-xs font-semibold">
                      {process.id}
                    </span>
                    <div className="flex flex-wrap gap-1.5 text-[11px] text-muted-foreground">
                      <MetricBadge icon={Clock3} label={`Arrival: ${process.arrivalTime}`} />
                      <MetricBadge icon={Gauge} label={`Burst: ${process.burstTime}`} />
                      <MetricBadge icon={Star} label={`Pri: ${process.priority}`} />
                    </div>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => removeProcess(process.id)}
                    className="h-7 w-7 text-muted-foreground opacity-0 transition-opacity group-hover:opacity-100 hover:text-destructive"
                    aria-label={`Delete ${process.id}`}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </Button>
                </div>
              </article>
            ))}
          </div>
        )}
      </div>

      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-background/70 p-4 backdrop-blur-sm">
          <div className="w-full max-w-lg overflow-hidden rounded-xl border border-border/70 bg-card shadow-2xl">
            <div className="flex items-start justify-between border-b border-border/70 px-5 py-4">
              <div>
                <h3 className="text-lg font-semibold">Add New Process</h3>
                <p className="text-xs text-muted-foreground">
                  Configure process parameters
                </p>
              </div>
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8"
                onClick={() => setIsAddOpen(false)}
                aria-label="Close"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>

            <div className="space-y-4 px-5 py-4">
              <ParameterField
                title="Arrival Time"
                subtitle="When the process enters the queue"
                value={draft.arrivalTime}
                min={0}
                max={100}
                onChange={(value) =>
                  setDraft((prev) => ({ ...prev, arrivalTime: value }))
                }
              />
              <ParameterField
                title="Burst Time"
                subtitle="CPU time required to complete"
                value={draft.burstTime}
                min={1}
                max={MAX_BURST_TIME}
                onChange={(value) =>
                  setDraft((prev) => ({ ...prev, burstTime: value }))
                }
              />
              <ParameterField
                title="Priority"
                subtitle="Higher number means higher priority"
                value={draft.priority}
                min={1}
                max={10}
                onChange={(value) =>
                  setDraft((prev) => ({ ...prev, priority: value }))
                }
              />
            </div>

            <div className="flex items-center justify-end gap-2 border-t border-border/70 px-5 py-4">
              <Button variant="outline" onClick={() => setIsAddOpen(false)}>
                Cancel
              </Button>
              <Button onClick={createProcess}>Add Process</Button>
            </div>
          </div>
        </div>
      )}

      {isScenarioOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-background/70 p-4 backdrop-blur-sm">
          <div className="w-full max-w-xl overflow-hidden rounded-xl border border-border/70 bg-card shadow-2xl">
            <div className="flex items-start justify-between border-b border-border/70 px-5 py-4">
              <div>
                <h3 className="text-lg font-semibold">Load Example Scenario</h3>
                <p className="text-xs text-muted-foreground">
                  Choose a pre-configured set of processes
                </p>
              </div>
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8"
                onClick={() => setIsScenarioOpen(false)}
                aria-label="Close"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>

            <div className="custom-scrollbar max-h-[340px] space-y-2 overflow-y-auto px-5 py-4">
              {PRESETS.map((preset, idx) => {
                const total = preset.processes.reduce(
                  (sum, item) => sum + item.burstTime,
                  0
                );
                const isActive = selectedPreset === idx;

                return (
                  <button
                    key={preset.name}
                    type="button"
                    className={`w-full rounded-lg border p-3 text-left transition ${
                      isActive
                        ? 'border-primary/50 bg-primary/10'
                        : 'border-border/70 bg-card/70 hover:border-border'
                    }`}
                    onClick={() => setSelectedPreset(idx)}
                  >
                    <div className="flex items-center justify-between gap-2">
                      <p className="text-sm font-semibold">{preset.name}</p>
                      <span className="rounded-full bg-muted px-2 py-0.5 text-[11px] text-muted-foreground">
                        {preset.processes.length} processes
                      </span>
                    </div>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {preset.description}
                    </p>
                    <p className="mt-2 text-[11px] text-muted-foreground">
                      Total burst: {total}
                    </p>
                  </button>
                );
              })}
            </div>

            <div className="flex items-center justify-end gap-2 border-t border-border/70 px-5 py-4">
              <Button variant="outline" onClick={() => setIsScenarioOpen(false)}>
                Cancel
              </Button>
              <Button onClick={loadSelectedScenario} disabled={selectedPreset == null}>
                Load Scenario
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

const MetricBadge = ({ icon: Icon, label }) => (
  <span className="inline-flex items-center gap-1 rounded border border-border/70 bg-muted/30 px-1.5 py-0.5">
    <Icon className="h-3 w-3" />
    {label}
  </span>
);

const ParameterField = ({ title, subtitle, value, min, max, onChange }) => (
  <div className="space-y-1 rounded-lg border border-border/70 bg-muted/25 p-3">
    <div>
      <Label className="text-sm font-medium">{title}</Label>
      <p className="text-xs text-muted-foreground">{subtitle}</p>
    </div>
    <Input
      type="number"
      min={min}
      max={max}
      value={value}
      onChange={(event) => onChange(Number.parseInt(event.target.value, 10) || min)}
      className="h-9 font-mono"
    />
  </div>
);

export default ProcessInput;
