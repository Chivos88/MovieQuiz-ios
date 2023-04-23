
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private let statisticService: StatisticService!
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator(isShow: true)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        self.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuestion(quiz: viewModel)
        }
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.showLoadingIndicator(isShow: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) {
            [weak self] in
            guard let self = self else { return }
            
            self.questionFactory?.requestNextQuestion()
            self.viewController?.showLoadingIndicator(isShow: true)
            self.questionFactory?.loadData()
            
        }
    }
    private func makeMessageForResult() -> String {
        let currentGameResultLine = "Ваш результат: \(self.correctAnswers) из \(self.questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(statisticService.bestGame.correct)\\\(statisticService.bestGame.total)"
        + " (\(statisticService.bestGame.date.dateTimeString))"
                let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
            
            let text = makeMessageForResult()
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            self.viewController?.showResult(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
            didAnswer(isCorrectAnswer: isCorrect)
            
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
    
    func showNetworkError(message: String, buttonAction: @escaping ()-> Void) {
        guard let viewController = viewController else { return }
        viewController.showLoadingIndicator(isShow: false)
        
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", completion: buttonAction)
        let alertPresenter = AlertPresenter(delegete: viewController)
        alertPresenter.showAlert(alertModel: alertModel)
    }
}
