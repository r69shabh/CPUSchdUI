# CPU Scheduler Visualizer

A beautiful native macOS application built with SwiftUI that visualizes CPU scheduling algorithms with realistic mock data and stunning animations.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green)

## Features

### 🎯 6 Scheduling Algorithms
- **FCFS** (First-Come, First-Served)
- **SJF** (Shortest Job First)
- **SRTF** (Shortest Remaining Time First)
- **Round Robin** (with adjustable time quantum)
- **Priority** (Non-Preemptive)
- **Priority** (Preemptive)

### 📊 Visualization
- **Interactive Gantt Charts** using Swift Charts
- **Animated timeline** with hover effects
- **Real-time metrics** display
- **Per-process analysis** with detailed tables

### 🔍 Analysis Tools
- **Side-by-side comparison** of multiple algorithms
- **Performance metrics**: Turnaround time, waiting time, response time, CPU utilization, throughput
- **Context switch** tracking
- **Bar charts** for metric comparison

### 📚 Educational Features
- **Interactive tutorials** on CPU scheduling concepts
- **Step-by-step explanations** for each algorithm
- **Quiz questions** to test understanding
- **Algorithm reference cards** with pros/cons

### 🖥️ System Monitor
- **Live CPU/memory graphs** with mock data
- **Process list** with sortable columns
- **Real-time updates** using Timer
- **Animated sparklines**

## Getting Started

### Requirements
- macOS 14.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Installation

1. **Clone or download** this repository
2. **Open** `CPUSchedulerUI.xcodeproj` in Xcode
3. **Select** "My Mac" as the run destination
4. **Press** ⌘R to build and run

### Quick Start

1. **Add Processes**
   - Click the `+` button in the Simulator tab
   - Choose "Load Scenario" for preset examples
   - Or add processes manually

2. **Select Algorithm**
   - Click the algorithm dropdown
   - Choose from 6 available algorithms
   - Adjust time quantum for Round Robin

3. **Run Simulation**
   - Click "Run" or press ⌘Return
   - Watch the animated Gantt chart appear
   - Scroll down for detailed metrics

4. **Compare Algorithms**
   - Switch to the Comparison tab
   - Toggle algorithm checkboxes
   - Load a scenario and click "Compare"

## Project Structure

```
CPUSchedulerUI/
├── Models/
│   ├── AppColors.swift          # Color palette & typography
│   ├── Process.swift             # Process & TimelineEvent models
│   ├── Algorithm.swift           # Algorithm definitions
│   ├── PerformanceMetrics.swift  # Metrics structures
│   ├── SchedulingResult.swift    # Result wrapper
│   └── Tutorial.swift            # Tutorial models
├── ViewModels/
│   ├── SimulatorViewModel.swift
│   ├── ComparisonViewModel.swift
│   ├── MonitorViewModel.swift
│   └── TutorialViewModel.swift
├── Views/
│   ├── MainWindowView.swift     # Split view with sidebar
│   ├── Simulator/               # Main simulation interface
│   ├── Visualization/           # Gantt charts
│   ├── Metrics/                 # Metrics display
│   ├── Comparison/              # Algorithm comparison
│   ├── Monitor/                 # System monitor
│   ├── Education/               # Tutorials
│   ├── Settings/                # Preferences
│   └── Components/              # Reusable UI components
├── Services/
│   ├── MockDataService.swift    # Realistic mock data generation
│   └── PreferencesService.swift # User preferences
└── Resources/
    └── Assets.xcassets/         # App icons & colors
```

## Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI with native macOS components
- **Charts**: Swift Charts for data visualization
- **State Management**: `@StateObject`, `@Published`, `@AppStorage`
- **Animations**: Spring animations, matched geometry effects

## Features in Detail

### Mock Data Service
Generates realistic scheduling results for all algorithms:
- **Timeline generation** based on algorithm logic
- **Metrics calculation** (TAT, WT, RT, CPU utilization, throughput)
- **5 preset scenarios** (Basic FCFS, SJF Optimization, Round Robin Demo, Priority Scheduling, Heavy Load)
- **Tutorial content** with 3 modules and quizzes

### UI Components
- **MetricCard**: Animated metric display with icons
- **ProcessRow**: Draggable process with color indicator
- **GlassCard**: Frosted glass material background
- **AnimatedButton**: Spring-animated button style
- **LoadingSpinner**: Rotating progress indicator

### Design System
- **Native macOS look** following Apple HIG
- **Dark mode support** throughout
- **System colors** with semantic meanings
- **Accessibility** labels and keyboard shortcuts

## Keyboard Shortcuts

- **⌘R** - Run simulation
- **⌘N** - New simulation
- **⌘L** - Load scenario
- **⌘⇧E** - Export results

## Customization

### Adding New Algorithms
1. Add algorithm to `AlgorithmInfo.all` in `Algorithm.swift`
2. Implement scheduling logic in `MockDataService.generateMockTimeline()`
3. Assign a unique color in `AppColors.swift`

### Modifying Presets
Edit `MockDataService.scenarios` to add/modify preset scenarios

### Changing Colors
Update `AppColors.swift` for the app-wide color palette

## Future Integration

This frontend is designed to integrate with a C/Kernel backend for real scheduling:
- Replace `MockDataService` calls with backend API
- Models are ready for JSON serialization
- Timeline events map directly to scheduling results

## License

This project is provided as-is for educational purposes.

## Credits

Built with ❤️ using SwiftUI and Swift Charts for macOS 14+
