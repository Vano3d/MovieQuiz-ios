//
//  User.swift
//  MovieQuiz
//
//  Created by Ivan Ch on 05.06.2023.
//

import Foundation

struct UserResults: Decodable {
    var items: [Film]
    
    struct Film: Decodable {
        var title: String
        var image: String
        var imDbRating: String
        
    }
}
