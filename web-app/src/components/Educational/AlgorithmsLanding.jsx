import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';
import { explanations } from '../../data/algorithmExplanations.js';
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

const AlgorithmsLanding = () => {
  return (
    <div className="max-w-7xl mx-auto p-6 animate-in fade-in duration-500">
      <div className="text-center mb-12 space-y-4">
        <h1 className="text-4xl font-extrabold text-foreground tracking-tight">
          Scheduling Algorithms
        </h1>
        <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
          Explore the fundamental algorithms that operating systems use to
          manage process execution. Understand their logic, advantages, and
          trade-offs.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {Object.values(explanations).map((algo) => (
          <Card
            key={algo.id}
            className="flex flex-col hover:shadow-md transition-shadow"
          >
            <CardHeader>
              <div className="flex items-start justify-between">
                <div className="p-3 bg-primary/10 text-primary rounded-lg mb-4">
                  <algo.icon size={24} />
                </div>
                <div className="flex gap-2">
                  {/* I will assume I have Badge component, if not I will simulate it or use div */}
                  <span className="inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80">
                    {algo.complexity}
                  </span>
                </div>
              </div>
              <CardTitle className="text-xl">{algo.title}</CardTitle>
            </CardHeader>
            <CardContent className="flex-1">
              <p className="text-muted-foreground line-clamp-3">
                {algo.shortDesc}
              </p>
              <div className="mt-4">
                <span className="inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-muted text-muted-foreground hover:bg-muted/80">
                  {algo.preemptive === 'Yes' ? 'Preemptive' : 'Non-Preemptive'}
                </span>
              </div>
            </CardContent>
            <CardFooter className="bg-muted/30 pt-6">
              <Button
                variant="ghost"
                className="w-full justify-between hover:bg-transparent hover:text-primary group-hover:underline p-0 h-auto"
                asChild
              >
                <Link
                  to={`/algorithms/${algo.id}`}
                  className="flex items-center w-full"
                >
                  <span className="font-medium text-primary">Learn More</span>
                  <ArrowRight size={18} className="text-primary ml-2" />
                </Link>
              </Button>
            </CardFooter>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default AlgorithmsLanding;
