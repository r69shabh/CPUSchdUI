import {
  Activity,
  ArrowLeftRight,
  Hourglass,
  ListChecks,
  Timer,
} from 'lucide-react';
import useSchedulerStore from '../../hooks/useScheduler';
import { Card, CardContent } from '@/components/ui/card';
import { calculateContextSwitches } from '../../utils/calculations';

const metricConfig = [
  {
    key: 'avgTurnaroundTime',
    title: 'Avg Turnaround',
    unit: 'units',
    icon: Timer,
    tone: 'text-blue-600 dark:text-blue-400',
    format: (value) => value.toFixed(2),
  },
  {
    key: 'avgWaitingTime',
    title: 'Avg Waiting',
    unit: 'units',
    icon: Hourglass,
    tone: 'text-amber-600 dark:text-amber-400',
    format: (value) => value.toFixed(2),
  },
  {
    key: 'avgResponseTime',
    title: 'Avg Response',
    unit: 'units',
    icon: Activity,
    tone: 'text-emerald-600 dark:text-emerald-400',
    format: (value) => value.toFixed(2),
  },
  {
    key: 'contextSwitches',
    title: 'Context Switches',
    unit: 'switches',
    icon: ArrowLeftRight,
    tone: 'text-cyan-600 dark:text-cyan-400',
    format: (value) => value,
  },
  {
    key: 'completionTime',
    title: 'Completion Time',
    unit: 'units',
    icon: ListChecks,
    tone: 'text-violet-600 dark:text-violet-400',
    format: (value) => value,
  },
];

const MetricsOverview = () => {
  const { results } = useSchedulerStore();

  if (!results || !results.metrics) {
    return null;
  }

  const contextSwitches = calculateContextSwitches(results.ganttChart);
  const completionTime =
    results.ganttChart && results.ganttChart.length > 0
      ? results.ganttChart[results.ganttChart.length - 1].end
      : 0;

  return (
    <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
      {metricConfig.map((metric) => {
        const Icon = metric.icon;
        const value =
          metric.key === 'contextSwitches'
            ? contextSwitches
            : metric.key === 'completionTime'
              ? completionTime
            : results.metrics[metric.key] ?? 0;

        return (
          <Card key={metric.key} className="border-border/80 bg-muted/20 shadow-none">
            <CardContent className="p-4">
              <div className="mb-2 flex items-center justify-between">
                <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  {metric.title}
                </p>
                <Icon className={`h-4 w-4 ${metric.tone}`} />
              </div>
              <p className={`text-2xl font-semibold tracking-tight ${metric.tone}`}>
                {metric.format(value)}
                <span className="ml-1 text-xs font-medium text-muted-foreground">
                  {metric.unit}
                </span>
              </p>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
};

export default MetricsOverview;
