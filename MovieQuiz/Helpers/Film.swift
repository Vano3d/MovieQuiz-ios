//
//  User.swift
//  MovieQuiz
//
//  Created by Ivan Ch on 05.06.2023.
//

import Foundation

struct UserResults: Decodable {
    let items: [User]
    
    struct User: Decodable {
        var title: String
        var image: String
        var imDbRating: String
        
    }
}
