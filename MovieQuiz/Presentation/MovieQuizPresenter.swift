import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewController?
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
    func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
    func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        viewController?.activityIndicator.stopAnimating()
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    func showNextQuestionOrResults() {
        viewController?.imageView.layer.borderWidth = 0
        viewController?.isEnabledButton(true)
        if self.isLastQuestion() {
            viewController?.showFinalResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.imageView.layer.borderWidth = 0
            viewController?.isEnabledButton(true)
        }
    }
    
}


