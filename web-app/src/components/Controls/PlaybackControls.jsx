import { Play, Trash2 } from 'lucide-react';
import useSchedulerStore from '../../hooks/useScheduler';
import { Button } from '@/components/ui/button';

const PlaybackControls = () => {
  const { runScheduler, setProcesses, processes } = useSchedulerStore();

  const handleRun = () => {
    runScheduler();
  };

  const handleClear = () => {
    setProcesses([]);
  };

  return (
    <div className="flex items-center gap-2">
      <Button
        variant="outline"
        size="sm"
        onClick={handleClear}
        title="Clear all processes"
        className="h-8 gap-2 rounded-lg"
        disabled={processes.length === 0}
      >
        <Trash2 className="h-4 w-4" />
        Clear
      </Button>
      <Button
        variant="default"
        size="sm"
        onClick={handleRun}
        title="Run scheduler"
        className="h-8 gap-2 rounded-lg px-3"
        disabled={processes.length === 0}
      >
        <Play className="h-4 w-4" />
        Run
      </Button>
    </div>
  );
};

export default PlaybackControls;
