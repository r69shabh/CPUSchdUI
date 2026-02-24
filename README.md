# CPU Scheduler Project

A comprehensive CPU scheduling simulation and visualization project with both web and native applications.

## Repository Structure

This repository contains two main applications:

### 📱 Native App (`/native-app`)

A macOS native application built with SwiftUI (frontend in `app`) and C/C++ (backend in `backend`) that provides CPU scheduling simulation and visualization.

**Features:**

- Interactive CPU scheduling simulator
- Support for multiple scheduling algorithms (FCFS, SJF, Priority, Round Robin, etc.)
- Real-time Gantt chart visualization
- Performance metrics analysis
- Algorithm comparison tools
- System monitoring capabilities
- Educational tutorials

**Tech Stack:**

- Swift
- SwiftUI
- C/C++ (Backend)
- macOS native APIs

**Getting Started:**

```bash
cd native-app/app
# Open in Xcode
open CPUSchedulerUI.xcodeproj
```

### 🌐 Web App (`/web-app`)

A modern web application built with React and Vite for CPU scheduling simulation and learning.

**Features:**

- Interactive web-based scheduling simulator
- Multiple scheduling algorithms implementation
- Visual Gantt charts and metrics
- Algorithm comparison view
- Educational content
- Dark/Light theme support
- Responsive design

**Tech Stack:**

- React
- Vite
- TailwindCSS
- Shadcn UI

**Getting Started:**

```bash
cd web-app
npm install
npm run dev
```

## Project Overview

This project provides educational tools for understanding CPU scheduling algorithms used in operating systems. Both applications offer similar features but cater to different platforms and use cases:

- **Native App**: Best for macOS users seeking a native desktop experience with system integration
- **Web App**: Cross-platform solution accessible from any modern web browser

## Supported Algorithms

Both applications implement the following CPU scheduling algorithms:

1. **First Come First Served (FCFS)**
2. **Shortest Job First (SJF)**
3. **Shortest Remaining Time First (SRTF)**
4. **Priority Scheduling** (Non-preemptive)
5. **Priority Scheduling** (Preemptive)
6. **Round Robin (RR)**

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is part of an academic OS course assignment.

## Authors

- Native App Development ([@r69shabh](https://github.com/r69shabh))
- Web App Development ([@Yash121l](https://github.com/Yash121l))

