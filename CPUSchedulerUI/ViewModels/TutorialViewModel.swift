import SwiftUI
import Combine

// MARK: - Tutorial View Model
class TutorialViewModel: ObservableObject {
    @Published var modules: [TutorialModule] = MockDataService.tutorialModules
    @Published var selectedModule: TutorialModule?
    @Published var currentStepIndex: Int = 0
    @Published var quizAnswers: [UUID: Int] = [:]
    @Published var showQuizResults: Bool = false

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
        return currentStepIndex > 0
    }

    var progress: Double {
        guard let module = selectedModule, !module.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(module.steps.count)
    }

    func selectModule(_ module: TutorialModule) {
        withAnimation {
            selectedModule = module
            currentStepIndex = 0
            quizAnswers = [:]
            showQuizResults = false
        }
    }

    func nextStep() {
        guard canGoNext else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStepIndex += 1
        }
    }

    func previousStep() {
        guard canGoPrevious else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStepIndex -= 1
        }
    }

    func answerQuiz(questionID: UUID, answerIndex: Int) {
        quizAnswers[questionID] = answerIndex
    }

    func submitQuiz() {
        withAnimation {
            showQuizResults = true
        }
    }

    var quizScore: Int {
        guard let module = selectedModule else { return 0 }
        return module.quiz.filter { q in
            quizAnswers[q.id] == q.correctIndex
        }.count
    }

    func goBack() {
        withAnimation {
            selectedModule = nil
            currentStepIndex = 0
            quizAnswers = [:]
            showQuizResults = false
        }
    }
}
