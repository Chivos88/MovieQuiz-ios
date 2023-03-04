import UIKit

// для состояния "Вопрос задан"
struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

// для состояния "Результат квиза"
struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

// сам вопрос
struct QuizQuestion {
  let image: String
  let text: String
  let correctAnswer: Bool
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = convert(model: questions[currentQuestionIndex])
        showQuestion(quiz: viewModel)
    }
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var imagePreview: UIImageView!
    @IBOutlet weak private var indexQuestion: UILabel!
    @IBOutlet weak private var textQuestion: UILabel!
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
                correctAnswers += 1
            }
        
        imagePreview.layer.masksToBounds = true
        imagePreview.layer.borderWidth = 8
        imagePreview.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResults()
            }
    }
    
    private func showQuestion(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imagePreview.layer.borderColor = CGColor(red: 255, green: 255, blue: 255, alpha: 0)
        imagePreview.image = step.image
        textQuestion.text = step.question
        indexQuestion.text = step.questionNumber
    }

    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert)
            
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
                self.currentQuestionIndex = 0
                
                let viewModel = self.convert(model: questions[self.currentQuestionIndex])
                self.showQuestion(quiz: viewModel)
            }
            
        alert.addAction(action)
            
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questions.count - 1 {
          let text = "Ваш результат: \(correctAnswers) из 10"
          let viewModel = QuizResultsViewModel(
              title: "Этот раунд окончен!",
              text: text,
              buttonText: "Сыграть ещё раз")
          showResult(quiz: viewModel)
      } else {
        currentQuestionIndex += 1
          
        let viewModel = convert(model: questions[currentQuestionIndex])
        showQuestion(quiz: viewModel)
      }
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
}

