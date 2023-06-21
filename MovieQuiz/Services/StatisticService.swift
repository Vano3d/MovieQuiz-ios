import Foundation


protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    
    private var accuracy: Double {
        guard total != 0 else {
            return 0
        }
        return Double(correct) / Double(total)
    }
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        
        lhs.accuracy < rhs.accuracy
    }
    
     
}

private enum Keys: String {
    case correct, total, bestGame, gamesCount
}

private let userDefaults = UserDefaults.standard

final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        
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
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var currentGameResult: Int
    var gamesCount: Int
    var totalAccuracy: Double
    
    init(currentGameResult: Int, gamesCount: Int, totalAccuracy: Double) {
        self.currentGameResult = currentGameResult
        self.gamesCount = gamesCount
        self.totalAccuracy = totalAccuracy
    }
}


