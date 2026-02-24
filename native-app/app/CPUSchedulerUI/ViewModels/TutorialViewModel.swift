import SwiftUI
import Combine

// MARK: - Tutorial View Model
class TutorialViewModel: ObservableObject {
    @Published var modules: [TutorialModule] = MockDataService.tutorialModules
    @Published var selectedModule: TutorialModule?
    @Published var currentStepIndex: Int = 0
    @Published var quizAnswers: [UUID: Int] = [:]
    @Published var showQuizResults: Bool = false
    @Published var inQuizMode: Bool = false
    @Published var completedModuleIDs: Set<UUID> = []

    var currentStep: TutorialStep? {
        guard let module = selectedModule,
              currentStepIndex < module.steps.count else { return nil }
        return module.steps[currentStepIndex]
    }

    var canGoNext: Bool {
        guard let module = selectedModule else { return false }
        return currentStepIndex < module.steps.count - 1
    }

    var canGoPrevious: Bool {
        return currentStepIndex > 0 && !inQuizMode
    }

    var progress: Double {
        guard let module = selectedModule else { return 0 }

        if inQuizMode {
            return 1.0
        }

        guard !module.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(module.steps.count)
    }

    var moduleCompletionRatio: Double {
        guard !modules.isEmpty else { return 0 }
        return Double(completedModuleIDs.count) / Double(modules.count)
    }

    var isSelectedModuleCompleted: Bool {
        guard let module = selectedModule else { return false }
        return completedModuleIDs.contains(module.id)
    }

    func selectModule(_ module: TutorialModule) {
        withAnimation {
            selectedModule = module
            currentStepIndex = 0
            quizAnswers = [:]
            showQuizResults = false
            inQuizMode = false
        }
    }

    func nextStep() {
        guard let module = selectedModule else { return }

        if canGoNext {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentStepIndex += 1
            }
            return
        }

        if !module.quiz.isEmpty {
            startQuiz()
        } else {
            markCurrentModuleCompleted()
        }
    }

    func previousStep() {
        guard canGoPrevious else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStepIndex -= 1
        }
    }

    func startQuiz() {
        guard let module = selectedModule, !module.quiz.isEmpty else { return }
        withAnimation {
            inQuizMode = true
            showQuizResults = false
        }
    }

    func exitQuiz() {
        withAnimation {
            inQuizMode = false
            showQuizResults = false
        }
    }

    func answerQuiz(questionID: UUID, answerIndex: Int) {
        quizAnswers[questionID] = answerIndex
    }

    func submitQuiz() {
        withAnimation {
            showQuizResults = true
        }

        if let module = selectedModule {
            completedModuleIDs.insert(module.id)
        }
    }

    var quizScore: Int {
        guard let module = selectedModule else { return 0 }
        return module.quiz.filter { q in
            quizAnswers[q.id] == q.correctIndex
        }.count
    }

    var isQuizComplete: Bool {
        guard let module = selectedModule else { return false }
        return module.quiz.allSatisfy { quizAnswers[$0.id] != nil }
    }

    func markCurrentModuleCompleted() {
        guard let module = selectedModule else { return }
        completedModuleIDs.insert(module.id)
    }

    func restartCurrentModule() {
        guard let selectedModule else { return }
        selectModule(selectedModule)
    }

    func goBack() {
        withAnimation {
            selectedModule = nil
            currentStepIndex = 0
            quizAnswers = [:]
            showQuizResults = false
            inQuizMode = false
        }
    }
}
