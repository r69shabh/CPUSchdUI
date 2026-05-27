import {
  BarChart3,
  Cpu,
  Play,
  PlusCircle,
  ArrowRightLeft,
  ArrowRight,
} from 'lucide-react';
import useSchedulerStore from '../../hooks/useScheduler';
import { getAlgorithmMeta } from '../../utils/algorithmMeta';
import { calculateContextSwitches } from '../../utils/calculations';
import GanttChart from './GanttChart';
import MetricsOverview from '../Metrics/MetricsOverview';
import MetricsTable from '../Metrics/MetricsTable';

const ResultsPanel = () => {
  const { results, selectedAlgorithm } = useSchedulerStore();
  const algoMeta = getAlgorithmMeta(selectedAlgorithm);

  if (!results) {
    return (
      <div className="flex h-full min-h-0 flex-col items-center justify-center px-8 py-10">
        <div className="mb-7 flex h-28 w-28 items-center justify-center rounded-full bg-primary/10">
          <BarChart3 className="h-12 w-12 text-primary/80" />
        </div>
        <h3 className="text-3xl font-semibold tracking-tight">Ready to Visualize</h3>
        <p className="mt-3 max-w-md text-center text-sm text-muted-foreground">
          Add processes and click Run to see the scheduling visualization
        </p>

        <div className="mt-8 w-full max-w-sm rounded-xl border border-primary/25 bg-primary/5 p-4">
          <QuickStartStep icon={PlusCircle} text="Add processes using the + button" />
          <QuickStartStep icon={Cpu} text="Select a scheduling algorithm" />
          <QuickStartStep icon={Play} text="Click Run to visualize" />
        </div>
      </div>
    );
  }

  const timeline = results.ganttChart ?? [];
  const contextSwitches = calculateContextSwitches(timeline);

  return (
    <div className="custom-scrollbar h-full min-h-0 min-w-0 overflow-y-auto">
      <section className="px-6 pb-5 pt-5">
        <div className="mb-4 flex items-center gap-3">
          <h3 className="text-base font-semibold">Timeline Visualization</h3>
          <div className="ml-auto flex items-center gap-1 rounded-full border border-border/80 bg-card/60 px-3 py-1 text-xs text-muted-foreground">
            {algoMeta.isPreemptive ? (
              <ArrowRightLeft className="h-3.5 w-3.5" />
            ) : (
              <ArrowRight className="h-3.5 w-3.5" />
            )}
            <span>{algoMeta.shortName}</span>
          </div>
        </div>

        <GanttChart />

        <div className="mt-5 space-y-2">
          <div className="flex items-center justify-between text-xs text-muted-foreground">
            <span className="font-medium">Execution Sequence</span>
            <span>
              {timeline.length} segments · {contextSwitches} switches
            </span>
          </div>
          <div className="custom-scrollbar max-w-full overflow-x-auto pb-1">
            <div className="inline-flex w-max min-w-full items-center gap-2">
              {timeline.map((segment, idx) => (
                <div key={`${segment.processId}-${idx}`} className="flex items-center gap-2">
                  {idx > 0 && <ArrowRight className="h-3 w-3 text-muted-foreground/60" />}
                  <div
                    className="rounded-md border border-border/70 px-2 py-1 text-[11px]"
                    style={{
                      backgroundColor: `${segment.color}22`,
                    }}
                  >
                    <span className="font-semibold">{segment.processId}</span>{' '}
                    <span className="text-muted-foreground">
                      t={segment.start}-{segment.end}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      <div className="border-t border-border/70" />

      <section className="space-y-4 px-6 py-5">
        <div className="space-y-1">
          <h3 className="text-base font-semibold">System Performance</h3>
          <p className="text-xs text-muted-foreground">
            Core scheduling outcomes based on turnaround, waiting, response, context switches, and completion time.
          </p>
        </div>
        <MetricsOverview />
        <MetricsTable />
      </section>
    </div>
  );
};

const QuickStartStep = ({ icon: Icon, text }) => (
  <div className="mb-3 flex items-center gap-3 last:mb-0">
    <div className="flex h-7 w-7 items-center justify-center rounded-full bg-primary/20">
      <Icon className="h-3.5 w-3.5 text-primary" />
    </div>
    <span className="text-sm">{text}</span>
  </div>
);

export default ResultsPanel;
