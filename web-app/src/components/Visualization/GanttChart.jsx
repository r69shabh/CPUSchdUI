import useSchedulerStore from '../../hooks/useScheduler';
import { motion, AnimatePresence } from 'framer-motion'; // eslint-disable-line no-unused-vars
import { Card } from '@/components/ui/card';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip';

const processSort = (a, b) => {
  const numA = Number.parseInt(String(a).replace(/\D/g, ''), 10);
  const numB = Number.parseInt(String(b).replace(/\D/g, ''), 10);

  if (Number.isNaN(numA) || Number.isNaN(numB)) {
    return String(a).localeCompare(String(b));
  }
  return numA - numB;
};

const GanttChart = () => {
  const { results, processes } = useSchedulerStore();

  if (!results || !results.ganttChart || results.ganttChart.length === 0) {
    return (
      <Card className="flex h-32 w-full items-center justify-center border-2 border-dashed bg-muted/20 text-muted-foreground shadow-none">
        {processes.length === 0
          ? 'Add processes to start'
          : 'No schedule generated'}
      </Card>
    );
  }

  const { ganttChart } = results;
  const totalTime = ganttChart[ganttChart.length - 1].end;

  const processOrder = Array.from(new Set(ganttChart.map((segment) => segment.processId))).sort(
    processSort
  );
  const rowHeight = 38;
  const barHeight = 24;
  const chartHeight = processOrder.length * rowHeight;
  const rowIndexByProcess = new Map(processOrder.map((id, index) => [id, index]));
  const allTimePoints = Array.from(
    new Set([0, ...ganttChart.map((segment) => segment.end)])
  ).sort((a, b) => a - b);
  const maxTicks = 14;
  const timePoints =
    allTimePoints.length <= maxTicks
      ? allTimePoints
      : (() => {
          const sampled = new Set([allTimePoints[0], allTimePoints[allTimePoints.length - 1]]);
          const step = (allTimePoints.length - 1) / (maxTicks - 1);
          for (let index = 1; index < maxTicks - 1; index += 1) {
            sampled.add(allTimePoints[Math.round(index * step)]);
          }
          return Array.from(sampled).sort((a, b) => a - b);
        })();

  return (
    <div className="flex w-full min-w-0 max-w-full items-start gap-3">
      <div className="w-14 shrink-0 pt-1">
        {processOrder.map((processId) => (
          <div
            key={`label-${processId}`}
            className="flex items-center justify-end pr-1 text-xs font-semibold text-muted-foreground"
            style={{ height: `${rowHeight}px` }}
          >
            {processId}
          </div>
        ))}
      </div>

      <div className="min-w-0 max-w-full flex-1 pb-2">
        <TooltipProvider>
          <div
            className="relative overflow-hidden rounded-xl border border-border/80 bg-card/70 shadow-sm"
            style={{ height: `${chartHeight}px` }}
          >
            {processOrder.map((processId, idx) => (
              <div
                key={`lane-${processId}`}
                className="absolute left-0 right-0 border-t border-border/35"
                style={{ top: `${idx * rowHeight + rowHeight / 2}px` }}
              />
            ))}

            <AnimatePresence>
              {ganttChart.map((segment, index) => {
                const row = rowIndexByProcess.get(segment.processId) ?? 0;
                const left = (segment.start / totalTime) * 100;
                const width = ((segment.end - segment.start) / totalTime) * 100;
                const top = row * rowHeight + (rowHeight - barHeight) / 2;

                return (
                  <Tooltip
                    key={`${segment.processId}-${index}-${segment.start}-${segment.end}`}
                  >
                    <TooltipTrigger asChild>
                      <motion.div
                        initial={{ opacity: 0, scaleY: 0 }}
                        animate={{ opacity: 1, scaleY: 1 }}
                        exit={{ opacity: 0, scaleY: 0 }}
                        transition={{ duration: 0.28, delay: index * 0.03 }}
                        className="absolute flex items-center justify-center rounded-md border border-white/20 px-1 text-xs font-bold text-white shadow-sm"
                        style={{
                          top: `${top}px`,
                          left: `${left}%`,
                          width: `${width}%`,
                          height: `${barHeight}px`,
                          backgroundColor: segment.color,
                        }}
                      >
                        <span className="truncate">{segment.processId}</span>
                      </motion.div>
                    </TooltipTrigger>
                    <TooltipContent>
                      <div className="grid grid-cols-2 gap-x-3 text-xs">
                        <span className="text-muted-foreground">Process:</span>
                        <span>{segment.processId}</span>
                        <span className="text-muted-foreground">Start:</span>
                        <span>{segment.start}</span>
                        <span className="text-muted-foreground">End:</span>
                        <span>{segment.end}</span>
                        <span className="text-muted-foreground">Duration:</span>
                        <span>{segment.end - segment.start}</span>
                      </div>
                    </TooltipContent>
                  </Tooltip>
                );
              })}
            </AnimatePresence>
          </div>
        </TooltipProvider>

        <div className="relative mt-2 h-7 font-mono text-xs text-muted-foreground">
          {timePoints.map((time, index) => {
            const isFirst = index === 0;
            const isLast = index === timePoints.length - 1;
            const transform = isFirst
              ? 'translateX(0)'
              : isLast
                ? 'translateX(-100%)'
                : 'translateX(-50%)';

            return (
              <div
                key={`time-${time}`}
                className="absolute z-10 flex flex-col items-center"
                style={{
                  left: `${(time / totalTime) * 100}%`,
                  transform,
                }}
              >
                <div className="mb-1 h-2.5 w-px bg-border" />
                <span className="rounded border border-border bg-background px-1">
                  {time}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default GanttChart;
