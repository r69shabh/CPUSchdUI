import SwiftUI

// MARK: - Education View
struct EducationView: View {
    @StateObject private var viewModel = TutorialViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.selectedModule == nil {
                moduleListView
            } else {
                tutorialDetailView
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Module List
    private var moduleListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero section
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.08))
                            .frame(width: 80, height: 80)

                        Image(systemName: "book.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(.blue.gradient)
                    }

                    Text("Learn CPU Scheduling")
                        .font(.largeTitle.bold())

                    Text("Interactive tutorials and quizzes to master\nCPU scheduling algorithms")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Module cards
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                ], spacing: 16) {
                    ForEach(viewModel.modules) { module in
                        ModuleCard(module: module)
                            .onTapGesture {
                                viewModel.selectModule(module)
                            }
                    }
                }
                .padding(.horizontal, 40)

                // Algorithm reference cards
                VStack(alignment: .leading, spacing: 16) {
                    Text("Algorithm Quick Reference")
                        .font(.title2.bold())
                        .padding(.horizontal, 40)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ], spacing: 12) {
                        ForEach(AlgorithmInfo.all) { algo in
                            AlgorithmReferenceCard(algorithm: algo)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Tutorial Detail View
    @ViewBuilder
    private var tutorialDetailView: some View {
        if let module = viewModel.selectedModule {
            VStack(spacing: 0) {
                // Tutorial toolbar
                HStack {
                    Button(action: { viewModel.goBack() }) {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)

                    Spacer()

                    Text(module.title)
                        .font(.headline)

                    Spacer()

                    // Progress
                    Text("Step \(viewModel.currentStepIndex + 1) of \(module.steps.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                        Rectangle()
                            .fill(.blue.gradient)
                            .frame(width: geo.size.width * viewModel.progress)
                            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.progress)
                    }
                }
                .frame(height: 3)

                Divider()

                // Step content
                ScrollView {
                    if let step = viewModel.currentStep {
                        StepContentView(step: step)
                            .padding(40)
                            .id(step.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStepIndex)

                Divider()

                // Navigation
                HStack {
                    Button(action: { viewModel.previousStep() }) {
                        Label("Previous", systemImage: "chevron.left")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!viewModel.canGoPrevious)

                    Spacer()

                    // Step dots
                    HStack(spacing: 6) {
                        ForEach(0..<module.steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == viewModel.currentStepIndex ? Color.blue : Color.secondary.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == viewModel.currentStepIndex ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: viewModel.currentStepIndex)
                        }
                    }

                    Spacer()

                    if viewModel.canGoNext {
                        Button(action: { viewModel.nextStep() }) {
                            Label("Next", systemImage: "chevron.right")
                        }
                        .buttonStyle(.borderedProminent)
                    } else if !module.quiz.isEmpty {
                        Button(action: { viewModel.nextStep() }) {
                            Label("Take Quiz", systemImage: "questionmark.circle")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
        }
    }
}

// MARK: - Module Card
struct ModuleCard: View {
    let module: TutorialModule
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: module.icon)
                    .font(.title3)
                    .foregroundStyle(.blue.gradient)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(.headline)

                Text(module.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            HStack {
                Label("\(module.steps.count) steps", systemImage: "list.bullet")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                if !module.quiz.isEmpty {
                    Label("\(module.quiz.count) quiz", systemImage: "questionmark.circle")
                        .font(.caption2)
                        .foregroundStyle(.purple)
                }
            }
        }
        .padding(18)
        .frame(height: 200)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(isHovered ? Color.blue.opacity(0.4) : Color.secondary.opacity(0.2), lineWidth: 1)
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(color: .black.opacity(isHovered ? 0.1 : 0.04), radius: isHovered ? 12 : 4, y: isHovered ? 4 : 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Step Content View
struct StepContentView: View {
    let step: TutorialStep

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.12))
                        .frame(width: 52, height: 52)

                    Image(systemName: step.icon)
                        .font(.title2)
                        .foregroundStyle(.blue.gradient)
                }

                Text(step.title)
                    .font(.title.bold())
            }

            Text(step.content)
                .font(.body)
                .lineSpacing(6)
                .foregroundStyle(.primary.opacity(0.9))

            // Algorithm highlight if applicable
            if let algoID = step.highlightAlgorithm,
               let algo = AlgorithmInfo.all.first(where: { $0.id == algoID }) {
                AlgorithmReferenceCard(algorithm: algo)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: 700, alignment: .leading)
    }
}

// MARK: - Algorithm Reference Card
struct AlgorithmReferenceCard: View {
    let algorithm: AlgorithmInfo

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: algorithm.icon)
                .font(.title2)
                .foregroundStyle(algorithm.color.gradient)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(algorithm.name)
                        .font(.subheadline.bold())

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: algorithm.isPreemptive ? "arrow.triangle.swap" : "arrow.right")
                            .font(.caption2)
                        Text(algorithm.isPreemptive ? "Preemptive" : "Non-Preemptive")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
                }

                Text(algorithm.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(algorithm.color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(algorithm.color.opacity(0.15), lineWidth: 1)
        }
    }
}
