import Foundation

// MARK: - Tutorial Model
struct TutorialStep: Identifiable {
    let id: UUID
    let title: String
    let content: String
    let icon: String
    let highlightAlgorithm: String?

    init(title: String, content: String, icon: String, highlightAlgorithm: String? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.icon = icon
        self.highlightAlgorithm = highlightAlgorithm
    }
}

struct QuizQuestion: Identifiable {
    let id: UUID
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String

    init(question: String, options: [String], correctIndex: Int, explanation: String) {
        self.id = UUID()
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
    }
}

struct TutorialModule: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let steps: [TutorialStep]
    let quiz: [QuizQuestion]

    init(title: String, description: String, icon: String, steps: [TutorialStep], quiz: [QuizQuestion] = []) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.steps = steps
        self.quiz = quiz
    }
}
