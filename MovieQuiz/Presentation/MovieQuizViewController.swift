import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var currentQuestionIndex: Int = 1
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var imagePreview: UIImageView!
    @IBOutlet weak private var indexQuestion: UILabel!
    @IBOutlet weak private var textQuestion: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
    
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
                self?.showQuestion(quiz: viewModel)
            }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
        }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
                correctAnswers += 1
            }
        
        imagePreview.layer.masksToBounds = true
        imagePreview.layer.borderWidth = 8
        imagePreview.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
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
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) {
            self.currentQuestionIndex = 0
             
            self.questionFactory?.requestNextQuestion()
        
        }
        
        let alertPresenter = AlertPresenter(delegete: self)
        alertPresenter.showAlert(alertData: alertModel)
    }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount {
          self.statisticService?.store(correct: self.correctAnswers, total: self.questionsAmount)
          
          var text: String
          if let statisticService = self.statisticService {
              text = "Ваш результат: \(self.correctAnswers) из \(self.questionsAmount)\n"+"Количество сыграных квизов: \(String(describing: statisticService.gamesCount))\n"+"Рекорд: \(String(describing: statisticService.bestGame.correct))/\(String(describing: statisticService.bestGame.total)) (\(String(describing: statisticService.bestGame.date.dateTimeString)))\n"+"Средняя точность: \(String(format: "%.2f", self.statisticService?.totalAccuracy ?? 0))%"
          } else {
              text = "Что-то пошло не так"
          }
          let viewModel = QuizResultsViewModel(
              title: "Этот раунд окончен!",
              text: text,
              buttonText: "Сыграть ещё раз")
          showResult(quiz: viewModel)
      } else {
        currentQuestionIndex += 1
          
          questionFactory?.requestNextQuestion()
      }
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
}

