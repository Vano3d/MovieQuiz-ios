
import UIKit

class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    var correctAnswers = 0
    
    private let presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtoсol?
    private var statisticService: StatisticService?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        questionFactory?.loadData()
        
        textLabel.text = "Рейтинг этого фильма больше чем 8?"
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        
        presenter.viewController = self
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
        activityIndicator.startAnimating()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        activityIndicator.stopAnimating()
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func isEnabledButton(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        self.imageView.layer.borderWidth = 0
        self.isEnabledButton(true)
        if presenter.isLastQuestion() {
            showFinalResults()
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
            isEnabledButton(true)
        }
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        let delegate = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            buttonAction: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.showAlert(in: delegate)
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService,
              let bestGame = statisticService.bestGame else {
            assertionFailure("ошибка")
            return ""
        }
        let accuracy = String(format: "%.0f", statisticService.totalAccuracy)
        let resultMessage =
                """
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Ваш результат: \(correctAnswers) из \(presenter.questionsAmount)
                    Рекорд: \(bestGame.correct) из \(bestGame.total) от \(bestGame.date.dateTimeString)
                    Средняя точность: \(accuracy)%
                """
        return resultMessage
    }
    
     func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        isEnabledButton(false)
        activityIndicator.startAnimating()
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
            }
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
    }

    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let model = AlertModel(
            title: "Ошибка сети",
            message: message,
            buttonText: "Попробовать ещё раз",
            buttonAction: { [weak self] in
                guard let self = self else { return }
                questionFactory?.loadData()
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
            }
        )
        alertPresenter?.showAlert(in: model)
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
}

