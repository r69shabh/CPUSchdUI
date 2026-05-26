# CPU Scheduler Visualizer

A beautiful native macOS application built with SwiftUI that visualizes CPU scheduling algorithms with realistic mock data and stunning animations.

[![macOS](https://img.shields.io/badge/macOS-14.0+-blue.svg)](https://apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)

## Table of Contents

- [Features](#features)
- [Technical Logics](#technical-logics)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [License](#license)
- [Credits](#credits)

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

## Technical Logics

CPU scheduling determines which process in the ready queue is to be allocated the CPU. This visualization app demonstrates several fundamental scheduling algorithms, each with its unique logic:

### 1. First-Come, First-Served (FCFS)
- **Logic**: The simplest scheduling algorithm. Processes are assigned the CPU in the order they request it (FIFO queue).
- **Preemption**: Non-preemptive. Once a process gets the CPU, it keeps it until it releases the CPU, either by terminating or by requesting I/O.
- **Characteristics**: Easy to implement but can suffer from the "convoy effect" where short processes wait a long time for a single long process to finish, increasing average waiting time.

### 2. Shortest Job First (SJF)
- **Logic**: Associates with each process the length of its next CPU burst. The CPU is assigned to the process with the smallest next CPU burst.
- **Preemption**: Non-preemptive.
- **Characteristics**: Provably optimal in terms of minimizing the average waiting time for a given set of processes. The difficulty lies in accurately predicting the length of the next CPU request.

### 3. Shortest Remaining Time First (SRTF)
- **Logic**: The preemptive version of SJF. If a new process arrives with a CPU burst length shorter than what is left of the currently executing process, the CPU is preempted.
- **Preemption**: Preemptive.
- **Characteristics**: Extremely fast response times for short processes but can lead to starvation of long processes if short processes keep arriving.

### 4. Round Robin (RR)
- **Logic**: Similar to FCFS, but preemption is added to switch between processes. A small unit of time, called a time quantum or time slice, is defined. The CPU scheduler goes around the ready queue, allocating the CPU to each process for a time interval of up to one time quantum.
- **Preemption**: Preemptive.
- **Characteristics**: Excellent response time, especially for time-sharing systems. Performance depends heavily on the size of the time quantum.

### 5. Priority Scheduling (Non-Preemptive)
- **Logic**: A priority number is associated with each process. The CPU is allocated to the process with the highest priority (usually denoted by the lowest integer value).
- **Preemption**: Non-preemptive. Once a process gets the CPU, it runs until completion.
- **Characteristics**: Can lead to starvation of low-priority processes. A solution to starvation is aging (gradually increasing the priority of processes that wait in the system for a long time).

### 6. Priority Scheduling (Preemptive)
- **Logic**: Similar to non-preemptive priority, but if a newly arrived process has a higher priority than the currently running process, the CPU is preempted.
- **Preemption**: Preemptive.
- **Characteristics**: Ensures the most important task is always running, but increases context switching overhead.

## Getting Started

### Requirements
- macOS 14.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Installation

1. **Clone or download** this repository:
   ```bash
   git clone https://github.com/r69shabh/CPUSchdUI.git
   ```
2. **Open** `CPUSchedulerUI.xcodeproj` in Xcode.
3. **Select** "My Mac" as the run destination.
4. **Press** `⌘R` to build and run.

### Quick Start

1. **Add Processes**: Click the `+` button in the Simulator tab. You can choose "Load Scenario" for preset examples or add processes manually.
2. **Select Algorithm**: Click the algorithm dropdown to choose from the 6 available algorithms (adjust time quantum if using Round Robin).
3. **Run Simulation**: Click "Run" or press `⌘Return` to watch the animated Gantt chart appear. Scroll down for detailed metrics.
4. **Compare Algorithms**: Switch to the Comparison tab, toggle algorithm checkboxes, load a scenario, and click "Compare".

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

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please make sure to update tests as appropriate and adhere to the project's coding standards.

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. Let's build a welcoming and inclusive community.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Credits

Built with ❤️ using SwiftUI and Swift Charts for macOS 14+
