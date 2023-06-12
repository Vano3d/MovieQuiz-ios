// Простая версия задания, прошедшая code review

import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion? 
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
        
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func isEnabledButton(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showAlert(alertTitle: String, alertMessage: String, alertButtonTitle: String) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertButtonTitle, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
            
            self.imageView.layer.borderWidth = 0
            self.isEnabledButton(true)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showAlert(
                alertTitle: "Этот раунд окончен!",
                alertMessage: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                alertButtonTitle: "Сыграть ещё раз")
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
            
            imageView.layer.borderWidth = 0
            isEnabledButton(true)
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        isEnabledButton(false)
        
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
    
        @IBAction private func yesButtonClicked(_ sender: UIButton) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
        }
        
        @IBAction private func noButtonClicked(_ sender: UIButton) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
        }
    }
    
