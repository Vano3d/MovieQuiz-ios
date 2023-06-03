import UIKit

struct QuizQuestion {
  let image: String
  let rating: Float
  let ratingInQuestion = round(Float.random(in: 5...9) * 10) / 10.0
  var randomBool = Bool.random()
  var text: String {
      var lessOrMore = ""
//      randomBool ? lessOrMore = "больше" : lessOrMore = "меньше"
      switch randomBool {
      case true:
          lessOrMore = "больше"
      case false:
          lessOrMore = "меньше"
      }
      return "Рейтинг этого фильма \(lessOrMore) чем \(ratingInQuestion)?"
    }
  var correctAnswer: Bool {
      randomBool ? rating > ratingInQuestion : rating < ratingInQuestion
      }
}

struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            rating: 9.2),
        QuizQuestion(
            image: "The Dark Knight",
            rating: 9.0),
        QuizQuestion(
            image: "Kill Bill",
            rating: 8.2),
        QuizQuestion(
            image: "The Avengers",
            rating: 8.0),
        QuizQuestion(
            image: "Deadpool",
            rating: 8.0),
        QuizQuestion(
            image: "The Green Knight",
            rating: 6.6),
        QuizQuestion(
            image: "Old",
            rating: 5.8),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            rating: 4.3),
        QuizQuestion(
            image: "Tesla",
            rating: 5.1),
        QuizQuestion(
            image: "Vivarium",
            rating: 5.9)
    ]

final class MovieQuizViewController: UIViewController {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
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
    private func isButtonEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func clearResult() {
        currentQuestionIndex = 0
        let firstQuestion = questions[self.currentQuestionIndex]
        let viewModel = self.convert(model: firstQuestion)
        show(quiz: viewModel)
        correctAnswers = 0
        imageView.layer.borderWidth = 0
        isButtonEnabled(true)
    }
    
    private func showAlert(alertTitle: String, alertMessage: String, alertButtonTitle: String) {
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert)
    
        let action = UIAlertAction(title: alertButtonTitle, style: .default) { _ in
            self.clearResult()
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
            isButtonEnabled(true)
        }
    }
    
    private func redrawBorderColor(_ color: UIColor) {
        imageView.layer.borderColor = color.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        isButtonEnabled(false)
        
        if isCorrect {
            redrawBorderColor(UIColor.ypGreen)
            correctAnswers += 1

        } else {
            redrawBorderColor(UIColor.ypRed)
        }
    }
    
    private func buttonClickHandler(_ buttonState: Bool) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == buttonState)
    }
    
        @IBAction private func yesButtonClicked(_ sender: UIButton) {
            buttonClickHandler(true)
            
        }
        @IBAction private func noButtonClicked(_ sender: UIButton) {
            buttonClickHandler(false)
           
        }
    }

