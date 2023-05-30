import UIKit

struct QuizQuestion {
  let image: String
  let text: String
  let correctAnswer: Bool
}

struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]


final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private func showAlert(alertTitle: String, alertMessage: String, alertButtonTitle: String) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertButtonTitle, style: .default) { [self] _ in
            currentQuestionIndex = 0
            let firstQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
            correctAnswers = 0
            imageView.layer.borderWidth = 0
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[0]))
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 20
        
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
        guard currentQuestionIndex == questions.count - 1 else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
            imageView.layer.borderWidth = 0
            yesButton.isEnabled = true
            noButton.isEnabled = true
            return
        }
            showAlert(
                alertTitle: "Этот раунд окончен!",
                alertMessage: "Ваш результат: \(correctAnswers)/\(questions.count)",
                alertButtonTitle: "Сыграть ещё раз")
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        guard isCorrect else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResults()
            }
            return
        }
        imageView.layer.borderColor = UIColor.ypGreen.cgColor
        correctAnswers += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
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
    
