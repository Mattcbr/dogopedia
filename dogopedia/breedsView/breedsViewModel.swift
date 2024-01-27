//
//  breedsViewModel.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

class breedsViewModel {
    
    var controller: breedsViewController
    public var breeds: Set<Breed> = [] // Maybe make this a set?

    init(controller: breedsViewController) {
        self.controller = controller

        RequestMaker().requestBreeds(pageToRequest: 0) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(var breeds):

                for index in 0..<breeds.count {

                    RequestMaker().requestImageInformation(referenceId: breeds[index].reference_image_id) { url in
                        breeds[index].addImageUrl(url)
                        self.breeds = Set(breeds.map{$0})
                        controller.didLoadBreeds()
                    }
                }

            case .failure(let error):
                print("Error, should handle")
            }
        }
    }
}
