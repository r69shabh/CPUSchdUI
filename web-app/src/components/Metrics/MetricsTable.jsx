import useSchedulerStore from '../../hooks/useScheduler';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

const MetricsTable = () => {
  const { results } = useSchedulerStore();

  if (!results || !results.processes) {
    return (
      <div className="w-full text-center py-10 text-muted-foreground">
        Data unavailable
      </div>
    );
  }

  return (
    <div className="custom-scrollbar overflow-x-auto rounded-lg border border-border/80 bg-card/70">
      <Table className="min-w-[860px]">
        <TableHeader>
          <TableRow className="bg-muted/60 hover:bg-muted/60 font-medium">
            <TableHead className="w-[120px]">Process ID</TableHead>
            <TableHead>Arrival Time</TableHead>
            <TableHead>Burst Time</TableHead>
            <TableHead>Completion Time</TableHead>
            <TableHead className="text-primary font-bold">
              Turnaround Time
            </TableHead>
            <TableHead className="text-amber-600 dark:text-amber-500 font-bold">
              Waiting Time
            </TableHead>
            <TableHead>Response Time</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {results.processes.map((p) => (
            <TableRow key={p.id} className="hover:bg-muted/30">
              <TableCell className="font-medium flex items-center gap-2">
                <div
                  className="w-3 h-3 rounded-full shrink-0"
                  style={{ backgroundColor: p.color }}
                ></div>
                {p.id}
              </TableCell>
              <TableCell>{p.arrivalTime}</TableCell>
              <TableCell>{p.burstTime}</TableCell>
              <TableCell>{p.completionTime}</TableCell>
              <TableCell className="font-semibold text-primary">
                {p.turnaroundTime}
              </TableCell>
              <TableCell className="font-semibold text-amber-600 dark:text-amber-500">
                {p.waitingTime}
              </TableCell>
              <TableCell>{p.responseTime}</TableCell>
            </TableRow>
          ))}

          <TableRow className="border-t-2 border-primary/20 bg-primary/5 font-bold hover:bg-primary/10">
            <TableCell colSpan={4} className="text-right text-primary">
              Average
            </TableCell>
            <TableCell className="text-primary">
              {results.metrics.avgTurnaroundTime.toFixed(2)}
            </TableCell>
            <TableCell className="text-primary">
              {results.metrics.avgWaitingTime.toFixed(2)}
            </TableCell>
            <TableCell className="text-primary">
              {results.metrics.avgResponseTime.toFixed(2)}
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
  );
};

export default MetricsTable;
