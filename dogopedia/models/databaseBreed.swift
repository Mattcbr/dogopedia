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

    func toBreed(_ dbBreed: databaseBreed) -> Breed {

        let group = dbBreed.group
        let hasLoadedImageData = dbBreed.hasLoadedImageData
        let id = dbBreed.id
        let imageReference = dbBreed.imageReference
        let imageData = dbBreed.imageData
        let name = dbBreed.name
        let origin = dbBreed.origin
        let temperament = dbBreed.temperament

        return Breed(group: group, hasLoadedImageData: hasLoadedImageData, id: id, imageReference: imageReference, imageData: imageData, name: name, origin: origin, temperament: temperament)
    }
}
