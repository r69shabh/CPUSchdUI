import { useMemo } from 'react';
import useSchedulerStore from '../../hooks/useScheduler';
import { ALGORITHMS } from '../../utils/constants';
import * as algorithms from '../../algorithms';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { useTheme } from '../../hooks/useTheme';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

const ComparisonView = () => {
  const { processes, quantum } = useSchedulerStore();
  const { isDarkMode } = useTheme();

  // Chart customization based on theme
  const axisColor = isDarkMode ? '#9CA3AF' : '#4B5563';
  const gridColor = isDarkMode ? '#374151' : '#E5E7EB';
  const tooltipBg = isDarkMode ? '#1F2937' : '#FFFFFF';
  const tooltipBorder = isDarkMode ? '#374151' : '#E5E7EB';
  const tooltipText = isDarkMode ? '#F3F4F6' : '#111827';

  // Calculate metrics for all algorithms
  const comparisonData = useMemo(() => {
    if (processes.length === 0) return [];

    const algos = [
      { id: ALGORITHMS.FCFS, name: 'FCFS', func: algorithms.fcfs },
      { id: ALGORITHMS.SJF, name: 'SJF', func: algorithms.sjf },
      { id: ALGORITHMS.SRTF, name: 'SRTF', func: algorithms.srtf },
      {
        id: ALGORITHMS.RR,
        name: `RR (Q=${quantum})`,
        func: (p) => algorithms.roundRobin(p, { quantum }),
      },
      {
        id: ALGORITHMS.PRIORITY,
        name: 'Priority (NP)',
        func: algorithms.priority,
      },
      {
        id: ALGORITHMS.PRIORITY_PREEMPTIVE,
        name: 'Priority (P)',
        func: algorithms.priorityPreemptive,
      },
    ];

    return algos.map((algo) => {
      try {
        // Pass a deep copy to avoid mutation artifacts if any (though algo functions should be pure)
        const procCopy = JSON.parse(JSON.stringify(processes));
        const result = algo.func(procCopy);
        return {
          name: algo.name,
          avgTurnaroundTime: result.metrics.avgTurnaroundTime,
          avgWaitingTime: result.metrics.avgWaitingTime,
          avgResponseTime: result.metrics.avgResponseTime,
          throughput: result.metrics.throughput,
          cpuUtilization: result.metrics.cpuUtilization,
        };
      } catch (e) {
        console.error(`Error running ${algo.name}:`, e);
        return {
          name: algo.name,
          avgTurnaroundTime: 0,
          avgWaitingTime: 0,
          avgResponseTime: 0,
          throughput: 0,
          cpuUtilization: 0,
        };
      }
    });
  }, [processes, quantum]);

  if (processes.length === 0) {
    return (
      <Card className="glass-panel border-dashed py-10 text-center shadow-none">
        <CardContent className="text-muted-foreground">
          Please add processes in the Visualizer tab first.
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <Card className="glass-panel">
        <CardHeader>
          <CardTitle>Metrics Comparison (Lower is Better)</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-[400px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                data={comparisonData}
                margin={{ top: 20, right: 30, left: 20, bottom: 5 }}
              >
                <CartesianGrid
                  strokeDasharray="3 3"
                  vertical={false}
                  stroke={gridColor}
                />
                <XAxis
                  dataKey="name"
                  stroke={axisColor}
                  tick={{ fill: axisColor }}
                />
                <YAxis stroke={axisColor} tick={{ fill: axisColor }} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '8px',
                    border: `1px solid ${tooltipBorder}`,
                    boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
                    backgroundColor: tooltipBg,
                    color: tooltipText,
                  }}
                  itemStyle={{ color: tooltipText }}
                  labelStyle={{ color: tooltipText, fontWeight: 'bold' }}
                />
                <Legend />
                <Bar
                  dataKey="avgTurnaroundTime"
                  name="Avg Turnaround Time"
                  fill="#4F46E5"
                  radius={[4, 4, 0, 0]}
                />
                <Bar
                  dataKey="avgWaitingTime"
                  name="Avg Waiting Time"
                  fill="#10B981"
                  radius={[4, 4, 0, 0]}
                />
                <Bar
                  dataKey="avgResponseTime"
                  name="Avg Response Time"
                  fill="#F59E0B"
                  radius={[4, 4, 0, 0]}
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      <Card className="glass-panel">
        <CardHeader>
          <CardTitle>Detailed Metrics</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow className="bg-muted/60 hover:bg-muted/60 font-medium">
                <TableHead>Algorithm</TableHead>
                <TableHead>Avg Turnaround</TableHead>
                <TableHead>Avg Waiting</TableHead>
                <TableHead>Avg Response</TableHead>
                <TableHead>CPU Utilization</TableHead>
                <TableHead>Throughput</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {comparisonData.map((data) => (
                <TableRow key={data.name} className="hover:bg-muted/40">
                  <TableCell className="font-medium text-foreground">
                    {data.name}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {data.avgTurnaroundTime.toFixed(3)}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {data.avgWaitingTime.toFixed(3)}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {data.avgResponseTime.toFixed(3)}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {data.cpuUtilization.toFixed(1)}%
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {data.throughput.toFixed(3)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
};

export default ComparisonView;
