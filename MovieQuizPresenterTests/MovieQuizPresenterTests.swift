import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showNetworkError(alertModel: MovieQuiz.AlertModel) {
        <#code#>
    }
    
    func showQuestion(quiz step: MovieQuiz.QuizStepViewModel) {
        <#code#>
    }
    
    func showResult(quiz result: MovieQuiz.QuizResultsViewModel) {
        <#code#>
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        <#code#>
    }
    
    func showLoadingIndicator(isShow: Bool) {
        <#code#>
    }
    
    
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
} 
