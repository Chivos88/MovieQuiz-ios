
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let viewController = viewController else {return}
            viewController.statisticService?.store(correct: viewController.correctAnswers, total: self.questionsAmount)
            
            var text: String
            if let statisticService = viewController.statisticService {
                text = """
Ваш результат: \(viewController.correctAnswers) из \(self.questionsAmount)
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
}
