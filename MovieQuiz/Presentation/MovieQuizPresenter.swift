
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            
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
        
        viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
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
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let viewController = viewController else {return}
            viewController.statisticService?.store(correct: self.correctAnswers, total: self.questionsAmount)
            
            var text: String
            if let statisticService = viewController.statisticService {
                text = """
Ваш результат: \(self.correctAnswers) из \(self.questionsAmount)
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
            viewController.showResult(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            
            self.questionFactory?.requestNextQuestion()
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
