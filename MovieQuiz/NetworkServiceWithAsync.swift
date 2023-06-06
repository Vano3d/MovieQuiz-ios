//
//  NetworkServiceWithAsync.swift
//  MovieQuiz
//
//  Created by Ivan Ch on 05.06.2023.
//

import Foundation

class NetworkServiceWithAsync {
    static let shared = NetworkServiceWithAsync(); private init() {}
    
    private func createURL() -> URL? {
        let urlStr = "https://imdb-api.com/en/API/Top250Movies/k_4k0egwax"
        let url = URL(string: urlStr)
        return url
    }
    
    func fetchData() async throws -> UserResults {
        guard let url = createURL() else {
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
