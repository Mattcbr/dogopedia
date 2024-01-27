//
//  Breed.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

struct Breed: Codable, Hashable, Equatable {

    let id: Int
    let name: String
    let reference_image_id: String
    let breed_group: String?
    let origin: String?
    var imageUrl: String?

    mutating func addImageUrl(_ url: String?) {
        self.imageUrl = url
    }
}
