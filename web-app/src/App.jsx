import React from 'react';
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from 'react-router-dom';
import Header from './components/Layout/Header';
import ProcessInput from './components/Input/ProcessInput';
import ResultsPanel from './components/Visualization/ResultsPanel';
import AlgorithmSelector from './components/Controls/AlgorithmSelector';
import PlaybackControls from './components/Controls/PlaybackControls';
import ExportControls from './components/Controls/ExportControls';
import PresetSelector from './components/Input/PresetSelector';
import AlgorithmExplanation from './components/Educational/AlgorithmExplanation';
import AlgorithmsLanding from './components/Educational/AlgorithmsLanding';
import ComparisonView from './components/Comparison/ComparisonView';
import Terms from './components/Legal/Terms';
import Privacy from './components/Legal/Privacy';

const VisualizerWorkspace = () => (
  <section className="simulator-shell min-w-0 animate-in fade-in duration-500">
    <div className="simulator-toolbar border-b border-border/70 px-4 py-3 md:px-5">
      <div className="flex flex-wrap items-center gap-3">
        <AlgorithmSelector />
        <div className="ml-auto flex flex-wrap items-center gap-2">
          <PresetSelector />
          <PlaybackControls />
          <ExportControls />
        </div>
      </div>
    </div>

    <div className="simulator-body flex min-h-0 min-w-0 flex-1 overflow-hidden">
      <aside className="simulator-process-pane min-h-0 w-[clamp(270px,22vw,320px)] shrink-0 border-r border-border/70">
        <ProcessInput />
      </aside>
      <div className="min-h-0 min-w-0 flex-1">
        <ResultsPanel />
      </div>
    </div>
  </section>
);

function App() {
  return (
    <Router>
      <div className="app-shell relative flex h-screen min-h-screen flex-col overflow-hidden text-foreground selection:bg-primary/20 selection:text-primary">
        <Header />
        <div className="border-t border-border/70" />
        <main className="relative z-10 min-h-0 min-w-0 flex-1 overflow-hidden px-3 py-3 md:px-4 md:py-4">
          <Routes>
            <Route
              path="/"
              element={<Navigate to="/visualizer" replace />}
            />
            <Route path="/visualizer" element={<VisualizerWorkspace />} />
            <Route
              path="/algorithms"
              element={
                <div className="custom-scrollbar h-full overflow-y-auto rounded-xl border border-border/70 bg-card/40 p-5">
                  <AlgorithmsLanding />
                </div>
              }
            />
            <Route
              path="/algorithms/:id"
              element={
                <div className="custom-scrollbar h-full overflow-y-auto rounded-xl border border-border/70 bg-card/40 p-5">
                  <AlgorithmExplanation />
                </div>
              }
            />
            <Route
              path="/comparison"
              element={
                <div className="custom-scrollbar h-full overflow-y-auto rounded-xl border border-border/70 bg-card/40 p-5 animate-in fade-in duration-500">
                  <ComparisonView />
                </div>
              }
            />
            <Route
              path="/terms"
              element={
                <div className="custom-scrollbar h-full overflow-y-auto rounded-xl border border-border/70 bg-card/40 p-5">
                  <Terms />
                </div>
              }
            />
            <Route
              path="/privacy"
              element={
                <div className="custom-scrollbar h-full overflow-y-auto rounded-xl border border-border/70 bg-card/40 p-5">
                  <Privacy />
                </div>
              }
            />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
