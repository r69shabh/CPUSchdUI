import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

const Privacy = () => {
  return (
    <div className="max-w-4xl mx-auto p-6 animate-in fade-in duration-500">
      <Card className="border-border shadow-sm">
        <CardHeader>
          <CardTitle className="text-3xl font-bold">Privacy Policy</CardTitle>
          <p className="text-muted-foreground">
            Last updated: {new Date().toLocaleDateString()}
          </p>
        </CardHeader>
        <CardContent className="space-y-6 text-foreground">
          <section>
            <h2 className="text-xl font-semibold mb-2">
              1. Information Collection
            </h2>
            <p className="text-muted-foreground">
              We do not collect any personal identifiable information (PII) from
              users. All processing of scheduling algorithms happens locally in
              your browser.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-2">2. Analytics</h2>
            <p className="text-muted-foreground">
              We use Microsoft Clarity to understand how users interact with our
              website. This includes capturing behavioral metrics, heatmaps, and
              session replays to improve the product. Usage data is captured
              using first and third-party cookies.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-2">3. Local Storage</h2>
            <p className="text-muted-foreground">
              We use browser Local Storage to save your theme preferences
              (light/dark mode). This data resides exclusively on your device
              and is not transmitted to any server.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold mb-2">
              4. Changes to This Policy
            </h2>
            <p className="text-muted-foreground">
              We may update our Privacy Policy from time to time. We will notify
              you of any changes by posting the new Privacy Policy on this page.
            </p>
          </section>
        </CardContent>
      </Card>
    </div>
  );
};

export default Privacy;
