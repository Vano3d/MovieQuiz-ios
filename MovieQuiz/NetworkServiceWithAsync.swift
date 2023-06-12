//
//  NetworkServiceWithAsync.swift
//  MovieQuiz
//
//  Created by Ivan Ch on 05.06.2023.
//

import Foundation

class NetworkServiceWithAsync {
    static let shared = NetworkServiceWithAsync(); private init() {}
// Обращение к API IMDB по своему ключу
    func fetchData() async throws -> UserResults {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_4k0egwax") else {
            throw NetworkingError.badURL
            
        }
        let response = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let result = try decoder.decode(UserResults.self, from: response.0)
        
        return result
    }
}

enum NetworkingError: Error {
    case badURL, badRequest, badResponse, invalidData
    
}
