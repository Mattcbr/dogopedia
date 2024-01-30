//
//  detailsViewModel.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 30/01/2024.
//

import Foundation

class detailsViewModel {

    weak var controller: detailsViewController?
    let databaseManager: dbManager

    init(controller: detailsViewController) {
        
        self.controller = controller
        self.databaseManager = dbManager.shared
    }

    public func isFavorite(breedId: Int) -> Bool {

        self.databaseManager.breeds.contains(where: {$0.id == breedId})
    }

    public func didPressFavoriteButton(forBreed breed: Breed) {

        let isFavorite = self.isFavorite(breedId: breed.id)

        if isFavorite {
            self.databaseManager.removeBreed(id: breed.id)
        } else {
            self.databaseManager.addBreed(breed: breed)
        }

        self.controller?.setupFavButton()
    }
}
