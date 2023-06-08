//
//  UIImage+Extensions.swift
//  MovieQuiz
//
//  Created by Ivan Ch on 08.06.2023.
//

import Foundation

import UIKit

extension UIImageView {

    func setImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }

        // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)

            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
