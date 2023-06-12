// Простая версия задания, прошедшая code review

import UIKit


final class MovieQuizViewController: UIViewController {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion? 
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[0]))
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
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
            
            let firstQuestion = questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
            
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            showAlert(
                alertTitle: "Этот раунд окончен!",
                alertMessage: "Ваш результат: \(correctAnswers)/\(questions.count)",
                alertButtonTitle: "Сыграть ещё раз")
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
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
            let currentQuestion = questions[currentQuestionIndex]
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
        }
        
        @IBAction private func noButtonClicked(_ sender: UIButton) {
            let currentQuestion = questions[currentQuestionIndex]
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
        }
    }
    
