
import Foundation

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        get {
            guard let dataCorrect = userDefaults.data(forKey: Keys.correct.rawValue),
                  let recordCorrect = try? JSONDecoder().decode(Double.self, from: dataCorrect) else {
                return 0
            }
            guard let dataTotal = userDefaults.data(forKey: Keys.total.rawValue),
                  let recordTotal = try? JSONDecoder().decode(Double.self, from: dataTotal) else {
                return 0
            }
            return recordTotal != 0 ? recordCorrect/recordTotal*100 : recordCorrect/1*100
        }
    }
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
             return record
        }
    }
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат BestGame")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    init() {
        
    }
    
    func store(correct count: Int, total amount: Int) {
        var newValueCorrect: Double
        var newValueTotal: Double
        
        
        guard let dataGamesCount = try? JSONEncoder().encode(self.gamesCount+1) else {
            print("Невозможно сохранить результат gamesCount")
            return
        }
        userDefaults.set(dataGamesCount, forKey: Keys.gamesCount.rawValue)
        
        if let dataCurrentCorrect = userDefaults.data(forKey: Keys.correct.rawValue),
            let recordCurrentCorrect = try? JSONDecoder().decode(Double.self, from: dataCurrentCorrect) {
                newValueCorrect = recordCurrentCorrect + Double(count)
        } else {
            newValueCorrect = Double(count)
        }
        guard let dataCorrect = try? JSONEncoder().encode(newValueCorrect) else {
            print("Невозможно сохранить результат dataCorrect")
            return
        }
        userDefaults.set(dataCorrect, forKey: Keys.correct.rawValue)
        
        if let dataCurrentTotal = userDefaults.data(forKey: Keys.total.rawValue),
            let recordCurrentTotal = try? JSONDecoder().decode(Double.self, from: dataCurrentTotal) {
                newValueTotal = recordCurrentTotal + Double(amount)
        } else {
            newValueTotal = Double(amount)
        }
        guard let dataTotal = try? JSONEncoder().encode(newValueTotal) else {
            print("Невозможно сохранить результат dataTotal")
            return
        }
        userDefaults.set(dataTotal, forKey: Keys.total.rawValue)
        
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        
        if (self.bestGame < currentGame) {
            self.bestGame = currentGame
        }
        
    }
    
    
}
