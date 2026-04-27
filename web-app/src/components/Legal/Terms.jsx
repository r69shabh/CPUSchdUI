import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

const Terms = () => {
  return (
    <div className="max-w-4xl mx-auto p-6 animate-in fade-in duration-500">
      <Card className="border-border shadow-sm">
        <CardHeader>
          <CardTitle className="text-3xl font-bold">
            Terms and Conditions
          </CardTitle>
          <p className="text-muted-foreground">
            Last updated: {new Date().toLocaleDateString()}
          </p>
        </CardHeader>
        <CardContent className="space-y-6 text-foreground">
          <section>
            <h2 className="text-xl font-semibold mb-2">1. Introduction</h2>
            <p className="text-muted-foreground">
              Welcome to the CPU Scheduling Visualizer. By accessing this
              website, you agree to be bound by these Terms and Conditions.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-2">2. Usage License</h2>
            <p className="text-muted-foreground">
              This project is open-source and intended for educational purposes.
              You are free to use, modify, and distribute it under the MIT
              License, provided proper attribution is given to the original
              authors.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-2">3. Disclaimer</h2>
            <p className="text-muted-foreground">
              The materials on this website are provided on an 'as is' basis. We
              make no warranties, expressed or implied, and hereby disclaim and
              negate all other warranties including, without limitation, implied
              warranties or conditions of merchantability, fitness for a
              particular purpose, or non-infringement of intellectual property
              or other violation of rights.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-2">4. Limitations</h2>
            <p className="text-muted-foreground">
              In no event shall the developers be liable for any damages
              (including, without limitation, damages for loss of data or
              profit, or due to business interruption) arising out of the use or
              inability to use the materials on this website.
            </p>
          </section>
        </CardContent>
      </Card>
    </div>
  );
};

export default Terms;
