import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
        viewController?.showLoadingIndicator()
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func proceedToNextQuestionOrResults() {
        viewController?.isEnabledButton(true)
        if self.isLastQuestion() {
            showFinalResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.isEnabledButton(true)
        }
    }
    
    func dispatchOneSecond() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.isEnabledButton(false)
        viewController?.showLoadingIndicator()
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        dispatchOneSecond()
    }
    
    func showFinalResults() {
        statisticService?.store(correct: correctAnswers,
                                total: questionsAmount)
        
        let delegate = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultsMessage(),
            buttonText: "Сыграть ещё раз",
            buttonAction: { [weak self] in
                guard let self = self else { return }
                self.restartGame()
                questionFactory?.requestNextQuestion()
            }
        )
        viewController?.alertPresenter?.showAlert(in: delegate)
    }
    
    private func makeResultsMessage() -> String {
        guard let statisticService = statisticService,
              let bestGame = statisticService.bestGame else {
            assertionFailure("ошибка")
            return ""
        }
        let accuracy = String(format: "%.0f", statisticService.totalAccuracy)
        let resultMessage =
                """
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Ваш результат: \(correctAnswers) из \(questionsAmount)
                    Рекорд: \(bestGame.correct) из \(bestGame.total) от \(bestGame.date.dateTimeString)
                    Средняя точность: \(accuracy)%
                """
        return resultMessage
    }
    
}


