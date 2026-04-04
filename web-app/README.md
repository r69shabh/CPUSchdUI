# CPU Scheduling Visualizer

The CPU Scheduling Visualizer is an interactive educational tool designed to demonstrate how different CPU scheduling algorithms work. It provides real-time visualization of process execution, comparative analysis, and detailed metrics to help students and professionals understand operating system concepts.

## Purpose

- Visualize CPU scheduling algorithms in action
- Compare algorithm performance side-by-side
- Understand timing diagrams (Gantt charts)
- Calculate scheduling metrics automatically
- Calculate scheduling metrics automatically
- Learn through interactive experimentation
- **Persistence**: Automatically saves your processes and settings

## Supported Scheduling Algorithms

### 1. First Come First Served (FCFS)

- **Description**: Non-preemptive algorithm that executes processes in order of arrival
- **Logic**: Process with earliest arrival time executes first
- **Advantages**: Simple, fair, no starvation
- **Disadvantages**: Poor average waiting time, convoy effect
- **Use Case**: Batch systems, simple scenarios

### 2. Shortest Job First (SJF) - Non-Preemptive

- **Description**: Executes the process with shortest burst time first
- **Logic**: Among available processes, select the one with minimum burst time
- **Advantages**: Optimal average waiting time
- **Disadvantages**: Starvation possible, requires knowing burst time
- **Use Case**: Long-term scheduling

### 3. Shortest Remaining Time First (SRTF)

- **Description**: Preemptive version of SJF
- **Logic**: If new process arrives with shorter remaining time, preempt current
- **Advantages**: Better average waiting time than SJF
- **Disadvantages**: More context switches, starvation
- **Use Case**: Real-time systems

### 4. Round Robin (RR)

- **Description**: Preemptive algorithm with fixed time quantum
- **Logic**: Each process gets equal CPU time in circular order
- **Advantages**: Fair, no starvation, good response time
- **Disadvantages**: Performance depends on quantum size
- **Use Case**: Time-sharing systems, interactive systems
- **Special Parameter**: Time Quantum (1-10 units typically)

### 5. Priority Scheduling - Non-Preemptive

- **Description**: Executes highest priority process first
- **Logic**: Lower priority number = higher priority (or vice versa)
- **Advantages**: Important processes execute first
- **Disadvantages**: Starvation of low-priority processes
- **Use Case**: Real-time systems, system processes

### 6. Priority Scheduling - Preemptive

- **Description**: Higher priority process can preempt current execution
- **Logic**: If new process arrives with higher priority, preempt
- **Advantages**: Very responsive to high-priority tasks
- **Disadvantages**: Severe starvation possible
- **Use Case**: Hard real-time systems

## User Input Parameters

### Process Attributes

| Parameter        | Description                                | Range       | Required           | Default        |
| ---------------- | ------------------------------------------ | ----------- | ------------------ | -------------- |
| **Process ID**   | Unique identifier (P1, P2, etc.)           | String      | Yes                | Auto-generated |
| **Arrival Time** | When process enters ready queue            | 0-100 units | Yes                | 0              |
| **Burst Time**   | CPU time required                          | 1-50 units  | Yes                | -              |
| **Priority**     | Process priority (lower = higher priority) | 1-10        | For Priority algos | 5              |

### Algorithm Parameters

| Parameter               | Applicable To | Range      | Description                       |
| ----------------------- | ------------- | ---------- | --------------------------------- |
| **Time Quantum**        | Round Robin   | 1-10 units | Time slice per process            |
| **Context Switch Time** | All           | 0-2 units  | Overhead for switching (optional) |

### Input Methods

1. **Manual Entry**: Form-based input for each process
2. **Batch Input**: Paste CSV/table data
3. **Random Generation**: Auto-generate test cases
4. **Preset Examples**: Pre-configured scenarios for learning

## Process Data Structure

### Input Data Format

```jsx
{
  id: "P1",              // Process identifier
  arrivalTime: 0,        // When process arrives
  burstTime: 5,          // CPU time needed
  priority: 2,           // Priority level (optional)
  color: "#4A90E2"       // Visual identifier (auto-assigned)
}
```

### Extended Data (Calculated)

```jsx
{
  // Input data
  id: "P1",
  arrivalTime: 0,
  burstTime: 5,
  priority: 2,
  color: "#4A90E2",

  // Calculated fields
  completionTime: 5,      // When process finishes
  turnaroundTime: 5,      // CT - AT
  waitingTime: 0,         // TAT - BT
  responseTime: 0,        // First execution - AT
  remainingTime: 5,       // For preemptive algorithms
  startTime: 0,           // First execution time

  // Execution tracking
  executionIntervals: [   // For Gantt chart
    { start: 0, end: 5 }
  ]
}
```

## Output Metrics & Calculations

### Per-Process Metrics

#### 1. Completion Time (CT)

- **Definition**: Time at which process completes execution
- **Formula**: `CT = Time when last burst finishes`
- **Unit**: Time units

#### 2. Turnaround Time (TAT)

- **Definition**: Total time from arrival to completion
- **Formula**: `TAT = Completion Time - Arrival Time`
- **Unit**: Time units
- **Interpretation**: Lower is better

#### 3. Waiting Time (WT)

- **Definition**: Time spent in ready queue
- **Formula**: `WT = Turnaround Time - Burst Time`
- **Unit**: Time units
- **Interpretation**: Lower is better

#### 4. Response Time (RT)

- **Definition**: Time from arrival to first execution
- **Formula**: `RT = First Start Time - Arrival Time`
- **Unit**: Time units
- **Interpretation**: Important for interactive systems

### System-Wide Metrics

#### 1. Average Turnaround Time

```
Average TAT = (Sum of all TAT) / Number of Processes
```

#### 2. Average Waiting Time

```
Average WT = (Sum of all WT) / Number of Processes
```

#### 3. Average Response Time

```
Average RT = (Sum of all RT) / Number of Processes
```

#### 4. CPU Utilization

```
CPU Utilization = (Total Burst Time / Total Time) × 100%
```

#### 5. Throughput

```
Throughput = Number of Processes / Total Time
```

### Results Table Format

| Process ID   | Arrival Time | Burst Time | Completion Time | Turnaround Time | Waiting Time | Response Time |
| ------------ | ------------ | ---------- | --------------- | --------------- | ------------ | ------------- |
| P1           | 0            | 5          | 5               | 5               | 0            | 0             |
| P2           | 1            | 3          | 8               | 7               | 4            | 5             |
| P3           | 2            | 8          | 16              | 14              | 6            | 8             |
| P4           | 3            | 6          | 22              | 19              | 13           | 16            |
| **Averages** | -            | **5.5**    | -               | **11.25**       | **5.75**     | **7.25**      |

## Visualization Components

### 1. Gantt Chart (Timeline Visualization)

**Purpose**: Show process execution sequence over time

**Features**:

- Horizontal timeline with time markers
- Color-coded process blocks
- Process labels inside blocks
- Hover to show detailed timing
- Zoom and pan controls
- Context switch indicators

**Design Elements**:

```
[P1][P2][P1][P3][P2][P3]...
0   3   5   8  11  13  16  Time →
```

**Interaction**:

- Hover: Show process details (ID, start, end, duration)
- Click: Highlight process in table
- Scroll: Zoom timeline
- Drag: Pan view

### 2. Ready Queue Visualization

**Purpose**: Show processes waiting for CPU

**Features**:

- Real-time queue state at each time unit
- Process cards with key info
- Queue order indication
- Animation of processes entering/leaving

**Display**:

```
Time = 5
Ready Queue: [P3] [P4] [P5]
Running: P2
Completed: P1
```

### 3. Comparison Charts

#### Bar Chart: Average Metrics

- Compare average WT, TAT, RT across algorithms
- Grouped bars for multi-metric comparison
- Color-coded by algorithm
- Interactive legend

#### Line Chart: Timeline Comparison

- Show queue length over time
- CPU utilization over time
- Process state changes

### 4. Process State Diagram

**Purpose**: Educational view of process states

**States**:

- New → Ready → Running → Terminated
- Running → Ready (preemption)
- Running → Waiting (I/O, not typically shown)

**Visualization**:

- Circular flow diagram
- Highlight active transitions
- Show process count in each state

### 5. Step-by-Step Execution

**Purpose**: Teaching mode for understanding algorithm logic

**Features**:

- Play/Pause/Step controls
- Current time pointer
- Decision explanation text
- Algorithm pseudocode highlight
- Speed control (0.5x, 1x, 2x, 5x)

**Example Display**:

```
Time = 5
Decision: Process P1 completed.
Ready Queue: [P2, P3, P4]
Next: Select P2 (shortest remaining time = 3)
Action: Context switch to P2
```

### 6. Metrics Dashboard

**Purpose**: Summary statistics at a glance

**Layout**:

```
┌─────────────────┬─────────────────┐
│ Avg Wait: 5.75  │ Avg TAT: 11.25  │
├─────────────────┼─────────────────┤
│ CPU Util: 95%   │ Throughput: 0.18│
└─────────────────┴─────────────────┘
```

## Teaching Features

### 1. Algorithm Explanation Panel

**Content for Each Algorithm**:

- How it works (plain language)
- Step-by-step logic
- Advantages and disadvantages
- Real-world use cases
- Common misconceptions

**Example (FCFS)**:

```
How it works:
Processes are executed in the order they arrive,
like a queue at a ticket counter.

Steps:
1. Sort processes by arrival time
2. Execute first process completely
3. Move to next process
4. Repeat until all done

Advantages:
✓ Simple to understand and implement
✓ Fair - no starvation
✓ Low overhead

Disadvantages:
✗ Poor average waiting time
✗ Convoy effect (short processes wait for long ones)
✗ Not suitable for interactive systems
```

### 2. Interactive Quiz Mode

**Features**:

- Given a set of processes, predict the order
- Calculate expected metrics
- Check answers against actual execution
- Hints and explanations

### 3. Scenario Library

**Pre-built Examples**:

- Best case for FCFS
- Worst case for FCFS (convoy effect)
- Priority inversion problem
- Round Robin quantum comparison
- Starvation demonstration

### 4. Comparison Mode

**Features**:

- Run multiple algorithms simultaneously
- Side-by-side Gantt charts
- Metric comparison table
- Winner highlighting (lowest avg wait time)
- Analysis text explaining why one algorithm performs better

### 5. Export & Share

**Capabilities**:

- Export Gantt chart as PNG/SVG
- Export metrics as CSV
- Share configuration as URL
- Generate PDF report with all visualizations
- Copy pseudocode implementation

## Best Practices for UX

### Visual Design

1. **Color Coding**
   - Use distinct, accessible colors for each process
   - Maintain color consistency across all views
   - Provide colorblind-friendly palette option
   - Use semantic colors (green=completed, red=waiting)
2. **Typography**
   - Clear labels and legends
   - Monospace font for time values
   - Hierarchy: Headings > Subheadings > Body
3. **Layout**
   - Primary view: Gantt chart (largest space)
   - Secondary: Metrics table
   - Tertiary: Queue visualization, controls
   - Responsive design for mobile

### Interaction Design

1. **Input Validation**
   - Real-time validation with helpful errors
   - Prevent impossible values (negative time)
   - Suggest corrections (e.g., "Did you mean 5?")
2. **Progressive Disclosure**
   - Start with simple FCFS example
   - Unlock advanced features gradually
   - Collapsible explanation panels
3. **Feedback**
   - Loading indicators for calculations
   - Success messages for actions
   - Error messages with solutions
   - Undo/redo support
4. **Performance**
   - Smooth animations (60fps)
   - Efficient rendering for many processes (virtualization)
   - Debounced input handling

### Accessibility

1. **Keyboard Navigation**
   - Tab through all controls
   - Arrow keys for timeline navigation
   - Space/Enter for play/pause
2. **Screen Readers**
   - ARIA labels on all interactive elements
   - Table semantics for metrics
   - Status announcements for state changes
3. **Contrast & Readability**
   - WCAG AA compliance minimum
   - Adjustable text size
   - High contrast mode option

### Educational Effectiveness

1. **Scaffolding**
   - Start with 2-3 processes
   - Gradually increase complexity
   - Guided tutorials for each algorithm
2. **Multiple Representations**
   - Visual (Gantt chart)
   - Numerical (metrics table)
   - Textual (step-by-step explanation)
   - Animated (play mode)
3. **Immediate Feedback**
   - Show metrics update in real-time
   - Highlight differences when switching algorithms
   - Explain why metrics changed
4. **Exploration**
   - "What if" scenarios
   - Modify and re-run
   - Compare before/after

## Implementation Recommendations

### Technology Stack

**Frontend**:

- React.js for component architecture
- D3.js or Chart.js for visualizations
- Tailwind CSS for styling
- Framer Motion for animations

**Features**:

- Client-side only (no backend needed)
- Local storage for saving configurations
- Service worker for offline use

### Code Structure

```
src/
├── algorithms/
│   ├── fcfs.js
│   ├── sjf.js
│   ├── srtf.js
│   ├── roundRobin.js
│   └── priority.js
├── components/
│   ├── GanttChart.jsx
│   ├── MetricsTable.jsx
│   ├── ProcessInput.jsx
│   ├── AlgorithmSelector.jsx
│   ├── QueueVisualization.jsx
│   └── ComparisonView.jsx
├── utils/
│   ├── calculations.js
│   └── validation.js
└── App.jsx
```

### Algorithm Implementation Pattern

```jsx
function scheduleAlgorithm(processes) {
  // 1. Initialize
  let currentTime = 0;
  let completed = [];
  let ganttChart = [];

  // 2. Main scheduling loop
  while (completed.length < processes.length) {
    // 3. Select next process
    let nextProcess = selectProcess(readyQueue, currentTime);

    // 4. Execute process
    let executionTime = calculateExecution(nextProcess);

    // 5. Update state
    currentTime += executionTime;
    ganttChart.push({});

    // 6. Calculate metrics
    updateMetrics(nextProcess, currentTime);
  }

  // 7. Return results
  return { ganttChart, processes, metrics };
}
```

## Sample Use Cases

### 1. Student Learning

- Start with FCFS tutorial
- Complete interactive exercises
- Compare algorithms with same input
- Take assessment quiz

### 2. Teaching in Classroom

- Project visualizer during lecture
- Live demonstration of concepts
- Student submissions via shared URLs
- Homework assignments with scenarios

### 3. Interview Preparation

- Practice common scheduling problems
- Time yourself on metric calculations
- Learn algorithm trade-offs
- Review explanations before interviews

### 4. Research & Analysis

- Test custom scheduling algorithms
- Benchmark performance metrics
- Generate reports for papers
- Export data for further analysis

## Future Enhancements

1. **Multi-Core Scheduling**: Visualize scheduling across multiple CPUs
2. **I/O Operations**: Add I/O burst times and waiting states
3. **Aging**: Implement aging to prevent starvation
4. **Custom Algorithms**: Let users write their own scheduling logic
5. **Real-Time Constraints**: Add deadlines for real-time scheduling
6. **Energy Efficiency**: Show power consumption metrics
7. **Multilevel Queue**: Visualize multiple priority queues
8. **Mobile App**: Native iOS/Android applications
9. **Collaborative Mode**: Multiple users interact with same visualization
10. **AI Tutor**: Chatbot that answers questions about current execution

## Conclusion

A well-designed CPU Scheduling Visualizer combines:

- **Accuracy**: Correct implementation of algorithms
- **Clarity**: Intuitive visual representation
- **Interactivity**: Engaging exploration tools
- **Education**: Effective teaching aids
- **Aesthetics**: Beautiful, professional design
