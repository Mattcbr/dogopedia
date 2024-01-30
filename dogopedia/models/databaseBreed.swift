//
//  databaseBreed.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 30/01/2024.
//

import Foundation
import RealmSwift

class databaseBreed: Object {

    @Persisted var group: String?
    @Persisted var hasLoadedImageData: Bool = false
    @Persisted(primaryKey: true) var id: Int
    @Persisted var imageReference: String
    @Persisted var imageData: Data?
    @Persisted var name: String
    @Persisted var origin: String?
    @Persisted var temperament: String?
}

// MARK: Helper functions

extension databaseBreed {
    
    static func fromBreed(_ breed: Breed) -> databaseBreed {

        let dbBreed = databaseBreed()

        dbBreed.group = breed.group
        dbBreed.hasLoadedImageData = breed.hasLoadedImageData
        dbBreed.id = breed.id
        dbBreed.imageReference = breed.imageReference
        dbBreed.imageData = breed.imageData
        dbBreed.name = breed.name
        dbBreed.origin = breed.origin
        dbBreed.temperament = breed.temperament

        return dbBreed
    }

    func toBreed() -> Breed {

        let group = self.group
        let hasLoadedImageData = self.hasLoadedImageData
        let id = self.id
        let imageReference = self.imageReference
        let imageData = self.imageData
        let name = self.name
        let origin = self.origin
        let temperament = self.temperament

        return Breed(group: group, hasLoadedImageData: hasLoadedImageData, id: id, imageReference: imageReference, imageData: imageData, name: name, origin: origin, temperament: temperament)
    }
}
