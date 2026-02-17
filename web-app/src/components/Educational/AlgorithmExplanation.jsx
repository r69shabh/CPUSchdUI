import React from 'react';
import { useParams, Navigate, Link } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import useSchedulerStore from '../../hooks/useScheduler';
import { explanations } from '../../data/algorithmExplanations';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

const AlgorithmExplanation = ({ algorithmId }) => {
  const { id } = useParams();
  const { selectedAlgorithm } = useSchedulerStore();

  // Determine which algorithm to show: prop, param, or store
  const targetId = algorithmId || id || selectedAlgorithm;
  const info = explanations[targetId];

  // If viewing as a standalone page (via router), allow navigation back
  const isStandalone = !!id;

  if (!info) {
    return isStandalone ? <Navigate to="/algorithms" /> : null;
  }

  return (
    <div
      className={isStandalone ? 'max-w-4xl mx-auto p-6 space-y-6' : 'h-full'}
    >
      {isStandalone && (
        <Button variant="ghost" className="pl-0 hover:bg-transparent" asChild>
          <Link
            to="/algorithms"
            className="flex items-center gap-2 text-muted-foreground hover:text-primary"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to Algorithms
          </Link>
        </Button>
      )}

      <Card
        className={
          isStandalone
            ? 'border-border shadow-sm'
            : 'h-full border-border shadow-sm'
        }
      >
        <CardHeader>
          <div className="flex items-center gap-3">
            {isStandalone && (
              <div className="p-2 bg-primary/10 rounded-lg text-primary">
                <info.icon size={24} />
              </div>
            )}
            <CardTitle className={isStandalone ? 'text-2xl' : 'text-lg'}>
              {info.title}
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          <p className="text-muted-foreground leading-relaxed">
            {info.description}
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-green-500/10 p-4 rounded-lg border border-green-500/20">
              <h4 className="font-semibold text-green-600 dark:text-green-400 text-sm uppercase tracking-wide mb-3 flex items-center gap-2">
                Advantages
              </h4>
              <ul className="space-y-2">
                {info.pros.map((pro, i) => (
                  <li
                    key={i}
                    className="flex items-start gap-2 text-sm text-foreground"
                  >
                    <span className="text-green-500 mt-1.5 h-1.5 w-1.5 rounded-full bg-current shrink-0" />
                    {pro}
                  </li>
                ))}
              </ul>
            </div>
            <div className="bg-red-500/10 p-4 rounded-lg border border-red-500/20">
              <h4 className="font-semibold text-red-600 dark:text-red-400 text-sm uppercase tracking-wide mb-3 flex items-center gap-2">
                Disadvantages
              </h4>
              <ul className="space-y-2">
                {info.cons.map((con, i) => (
                  <li
                    key={i}
                    className="flex items-start gap-2 text-sm text-foreground"
                  >
                    <span className="text-red-500 mt-1.5 h-1.5 w-1.5 rounded-full bg-current shrink-0" />
                    {con}
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {info.realWorld && (
            <div className="bg-purple-500/10 p-4 rounded-lg border border-purple-500/20">
              <h4 className="font-semibold text-purple-600 dark:text-purple-400 text-sm uppercase tracking-wide mb-2">
                Real-World Applications
              </h4>
              <p className="text-foreground text-sm">{info.realWorld}</p>
            </div>
          )}
        </CardContent>
      </Card>

      {isStandalone && (
        <Card className="border-border shadow-sm">
          <CardHeader>
            <CardTitle className="text-lg">Technical Details</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-sm">
              <div>
                <span className="block text-muted-foreground mb-1">
                  Complexity
                </span>
                <span className="font-medium text-foreground">
                  {info.complexity}
                </span>
              </div>
              <div>
                <span className="block text-muted-foreground mb-1">
                  Preemptive
                </span>
                <span className="font-medium text-foreground">
                  {info.preemptive}
                </span>
              </div>
              <div>
                <span className="block text-muted-foreground mb-1">
                  Category
                </span>
                <span className="font-medium text-foreground">
                  CPU Scheduling
                </span>
              </div>
              <div>
                <span className="block text-muted-foreground mb-1">
                  Starvation
                </span>
                <span className="font-medium text-foreground">
                  {info.cons.some((c) => c.toLowerCase().includes('starvation'))
                    ? 'Possible'
                    : 'None'}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default AlgorithmExplanation;
