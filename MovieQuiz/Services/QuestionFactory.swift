import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    func loadData() {
            moviesLoader.loadMovies { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    case .failure(let error):
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
        }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                let index = (0..<self.movies.count).randomElement() ?? 0
                
                guard let movie = self.movies[safe: index] else { return }
                
                var imageData = Data()
               
               do {
                    imageData = try Data(contentsOf: movie.resizedImageURL)
                } catch {
                    print("Failed to load image")
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.showNetworkError(message: "Ошибка при загрузке изображения") { [weak self] in
                            guard let self = self else {return}
                             return self.requestNextQuestion()
                        }
                    }
                }
                
                let rating = Float(movie.rating) ?? 0
                
                
            let question = self.generateQuestion(image: imageData, rating: rating)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didRecieveNextQuestion(question: question)
                }
            }
    }
    private func generateQuestion(image: Data, rating: Float) -> QuizQuestion {
        let integer = rating == 10 ? 9 : floor(rating)
        
        // flag отвечает за знак "больше-меньше" true-> больше false-> меньше
        let flag = [true, false].randomElement() ?? false
        
        let text = "Рейтинг этого фильма \(flag ? "больше" : "меньше") чем \(integer)?"
        let correctAnswer = flag ? rating > integer : rating < integer
        
        return QuizQuestion(image: image, text: text, correctAnswer: correctAnswer)
    }
}
