//
//  Breed.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

struct Breed: Codable, Hashable, Equatable {

    let group: String?
    var hasLoadedImageData: Bool = false
    let id: Int
    let imageReference: String
    var imageURL: URL?
    let name: String
    let origin: String?
    let temperament: String?

    enum CodingKeys: String, CodingKey {
        case id, name, temperament, origin
        case imageReference = "reference_image_id"
        case group = "breed_group"
    }

    mutating func addImageUrl(_ url: URL?) {
        self.imageURL = url
        self.hasLoadedImageData = true
    }
}
