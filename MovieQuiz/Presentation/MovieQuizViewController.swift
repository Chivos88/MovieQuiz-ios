import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var imagePreview: UIImageView!
    @IBOutlet weak private var indexQuestion: UILabel!
    @IBOutlet weak private var textQuestion: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.requestNextQuestion()
        
        showLoadingIndicator(isShow: true)
        questionFactory?.loadData()
        
    }
    private func showLoadingIndicator(isShow: Bool) {
        if isShow {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imagePreview.layer.masksToBounds = true
        imagePreview.layer.borderWidth = 8
        imagePreview.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()        }
    }
    
    func showQuestion(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imagePreview.layer.borderColor = UIColor.clear.cgColor
        imagePreview.image = step.image
        textQuestion.text = step.question
        indexQuestion.text = step.questionNumber
    }
    
    func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
            self.questionFactory?.requestNextQuestion()
            
        }
        
        let alertPresenter = AlertPresenter(delegete: self)
        alertPresenter.showAlert(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService?.store(correct: self.correctAnswers, total: presenter.questionsAmount)
            
            var text: String
            if let statisticService = self.statisticService {
                text = """
Ваш результат: \(self.correctAnswers) из \(presenter.questionsAmount)
Количество сыграных квизов: \(String(describing: statisticService.gamesCount))
Рекорд: \(String(describing: statisticService.bestGame.correct))/\(String(describing: statisticService.bestGame.total)) (\(String(describing: statisticService.bestGame.date.dateTimeString)))
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
            } else {
                text = "Что-то пошло не так"
            }
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResult(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showNetworkError(message: String, buttonAction: @escaping ()-> Void) {
        showLoadingIndicator(isShow: false)
        
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", completion: buttonAction)
        let alertPresenter = AlertPresenter(delegete: self)
        alertPresenter.showAlert(alertModel: alertModel)
    }
    func didRecieveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        showLoadingIndicator(isShow: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) {
            [weak self] in
            guard let self = self else { return }
            
            self.questionFactory?.requestNextQuestion()
            self.showLoadingIndicator(isShow: true)
            self.questionFactory?.loadData()
            
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        presenter.noButtonClicked()
    }
    
}

