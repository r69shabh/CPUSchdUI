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
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(.blue.opacity(0.08))
                                .frame(width: 78, height: 78)
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.blue.gradient)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Learn CPU Scheduling")
                                .font(.largeTitle.bold())
                            Text("Interactive lessons, in-app practice, and quizzes.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        LearningProgressRing(progress: viewModel.moduleCompletionRatio)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 34)

                DecisionLabCard()
                    .padding(.horizontal, 34)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Modules")
                        .font(.title2.bold())

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14),
                    ], spacing: 14) {
                        ForEach(viewModel.modules) { module in
                            ModuleCard(
                                module: module,
                                isCompleted: viewModel.completedModuleIDs.contains(module.id)
                            )
                            .onTapGesture {
                                viewModel.selectModule(module)
                            }
                        }
                    }
                }
                .padding(.horizontal, 34)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Algorithm Quick Reference")
                        .font(.title3.bold())

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                    ], spacing: 12) {
                        ForEach(AlgorithmInfo.all) { algo in
                            AlgorithmReferenceCard(algorithm: algo)
                        }
                    }
                }
                .padding(.horizontal, 34)
                .padding(.bottom, 34)
            }
        }
    }

    // MARK: - Tutorial Detail View
    @ViewBuilder
    private var tutorialDetailView: some View {
        if let module = viewModel.selectedModule {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button(action: { viewModel.goBack() }) {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)

                    Divider()
                        .frame(height: 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(module.title)
                            .font(.headline)
                        Text(viewModel.inQuizMode ? "Quiz Mode" : "Step \(viewModel.currentStepIndex + 1) of \(module.steps.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if viewModel.isSelectedModuleCompleted {
                        Label("Completed", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(.green.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.secondary.opacity(0.2))
                        Rectangle()
                            .fill(.blue.gradient)
                            .frame(width: geo.size.width * viewModel.progress)
                            .animation(.spring(response: 0.35, dampingFraction: 0.84), value: viewModel.progress)
                    }
                }
                .frame(height: 3)

                Divider()

                Group {
                    if viewModel.inQuizMode {
                        ModuleQuizView(module: module, viewModel: viewModel)
                    } else if let step = viewModel.currentStep {
                        ScrollView {
                            StepContentView(step: step)
                                .padding(34)
                                .id(step.id)
                        }
                    }
                }

                Divider()

                tutorialFooter(module: module)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
        }
    }

    @ViewBuilder
    private func tutorialFooter(module: TutorialModule) -> some View {
        if viewModel.inQuizMode {
            HStack {
                Button("Back to Steps") {
                    viewModel.exitQuiz()
                }
                .buttonStyle(.bordered)

                Spacer()

                if viewModel.showQuizResults {
                    Text("Score: \(viewModel.quizScore)/\(module.quiz.count)")
                        .font(.subheadline.weight(.semibold))
                }

                Button(action: {
                    viewModel.submitQuiz()
                }) {
                    Label(viewModel.showQuizResults ? "Re-evaluate" : "Submit Quiz", systemImage: "checkmark.circle")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isQuizComplete)
            }
        } else {
            HStack {
                Button(action: { viewModel.previousStep() }) {
                    Label("Previous", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canGoPrevious)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<module.steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.currentStepIndex ? Color.blue : Color.secondary.opacity(0.28))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                if viewModel.canGoNext {
                    Button(action: { viewModel.nextStep() }) {
                        Label("Next", systemImage: "chevron.right")
                    }
                    .buttonStyle(.borderedProminent)
                } else if !module.quiz.isEmpty {
                    Button(action: { viewModel.startQuiz() }) {
                        Label("Start Quiz", systemImage: "questionmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                } else {
                    Button(action: { viewModel.markCurrentModuleCompleted() }) {
                        Label("Mark Complete", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

// MARK: - Module Card
struct ModuleCard: View {
    let module: TutorialModule
    let isCompleted: Bool
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.12))
                        .frame(width: 42, height: 42)

                    Image(systemName: module.icon)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
            }

            Text(module.title)
                .font(.headline)

            Text(module.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            HStack {
                Label("\(module.steps.count) steps", systemImage: "list.bullet")
                Spacer()
                if !module.quiz.isEmpty {
                    Label("\(module.quiz.count) quiz", systemImage: "questionmark.circle")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(height: 190)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isHovered ? Color.accentColor.opacity(0.5) : Color.secondary.opacity(0.2), lineWidth: 1)
        }
        .scaleEffect(isHovered ? 1.015 : 1)
        .animation(.spring(response: 0.24, dampingFraction: 0.86), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Step Content View
struct StepContentView: View {
    let step: TutorialStep

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: step.icon)
                        .font(.title3)
                        .foregroundStyle(.blue)
                }

                Text(step.title)
                    .font(.title2.bold())
            }

            Text(step.content)
                .font(.body)
                .lineSpacing(5)

            if let algoID = step.highlightAlgorithm,
               let algo = AlgorithmInfo.all.first(where: { $0.id == algoID }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Related Algorithm")
                        .font(.subheadline.weight(.semibold))
                    AlgorithmReferenceCard(algorithm: algo)
                }
            }
        }
        .frame(maxWidth: 760, alignment: .leading)
    }
}

// MARK: - Quiz View
private struct ModuleQuizView: View {
    let module: TutorialModule
    @ObservedObject var viewModel: TutorialViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Knowledge Check", systemImage: "brain.head.profile")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Text("\(module.quiz.count) questions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ForEach(module.quiz) { question in
                    QuizQuestionCard(
                        question: question,
                        selectedOption: viewModel.quizAnswers[question.id],
                        showResult: viewModel.showQuizResults,
                        onSelect: { selected in
                            viewModel.answerQuiz(questionID: question.id, answerIndex: selected)
                        }
                    )
                }

                if viewModel.showQuizResults {
                    Text(viewModel.quizScore == module.quiz.count
                         ? "Perfect score. Excellent work."
                         : "Module completed. Review explanations and retry anytime to improve your score.")
                        .font(.subheadline)
                        .foregroundStyle(viewModel.quizScore == module.quiz.count ? .green : .secondary)
                        .padding(.top, 6)
                }
            }
            .padding(28)
        }
    }
}

private struct QuizQuestionCard: View {
    let question: QuizQuestion
    let selectedOption: Int?
    let showResult: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question.question)
                .font(.subheadline.weight(.semibold))

            ForEach(question.options.indices, id: \.self) { optionIndex in
                Button {
                    onSelect(optionIndex)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: iconName(for: optionIndex))
                            .foregroundStyle(iconColor(for: optionIndex))
                        Text(question.options[optionIndex])
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(backgroundColor(for: optionIndex))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            if showResult {
                Text(question.explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func iconName(for option: Int) -> String {
        guard showResult else {
            return selectedOption == option ? "largecircle.fill.circle" : "circle"
        }

        if option == question.correctIndex {
            return "checkmark.circle.fill"
        }

        if selectedOption == option && option != question.correctIndex {
            return "xmark.circle.fill"
        }

        return selectedOption == option ? "largecircle.fill.circle" : "circle"
    }

    private func iconColor(for option: Int) -> Color {
        guard showResult else {
            return selectedOption == option ? .accentColor : .secondary
        }

        if option == question.correctIndex {
            return .green
        }

        if selectedOption == option && option != question.correctIndex {
            return .red
        }

        return .secondary
    }

    private func backgroundColor(for option: Int) -> Color {
        guard showResult else {
            return selectedOption == option ? .accentColor.opacity(0.12) : .secondary.opacity(0.08)
        }

        if option == question.correctIndex {
            return .green.opacity(0.14)
        }

        if selectedOption == option && option != question.correctIndex {
            return .red.opacity(0.12)
        }

        return .secondary.opacity(0.08)
    }
}

private struct LearningProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 7)
            Circle()
                .trim(from: 0, to: max(0.02, progress))
                .stroke(.blue.gradient, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 0.86), value: progress)

            VStack(spacing: 1) {
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                Text("done")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 62, height: 62)
    }
}

private struct DecisionLabCard: View {
    enum Goal: String, CaseIterable, Identifiable {
        case response = "Fast Response"
        case fairness = "Fairness"
        case throughput = "Throughput"

        var id: String { rawValue }
    }

    @State private var selectedGoal: Goal = .response

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Decision Lab", systemImage: "slider.horizontal.3")
                    .font(.headline)
                Spacer()
                Text("Interactive")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.purple.opacity(0.13))
                    .clipShape(Capsule())
            }

            Text("Choose an OS objective and see a recommended scheduling strategy.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Goal", selection: $selectedGoal) {
                ForEach(Goal.allCases) { goal in
                    Text(goal.rawValue).tag(goal)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 4) {
                Text("Recommended: \(recommendationTitle)")
                    .font(.subheadline.weight(.semibold))
                Text(recommendationBody)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var recommendationTitle: String {
        switch selectedGoal {
        case .response:
            return "Round Robin or Priority (Preemptive)"
        case .fairness:
            return "Round Robin"
        case .throughput:
            return "SJF or SRTF"
        }
    }

    private var recommendationBody: String {
        switch selectedGoal {
        case .response:
            return "Short time slices or preemption let new tasks start sooner, improving perceived responsiveness."
        case .fairness:
            return "RR prevents one process from monopolizing CPU by rotating equal execution windows."
        case .throughput:
            return "Shortest-job strategies usually complete more processes quickly on mixed workloads."
        }
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
                        Text(algorithm.isPreemptive ? "Preemptive" : "Non-preemptive")
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
                .strokeBorder(algorithm.color.opacity(0.18), lineWidth: 1)
        }
    }
}
