//
//  breedsViewModel.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

class breedsViewModel {
    
    let controller: breedsViewController?
    let networkRequester: networkRequester
    public var breeds: Set<Breed> = []

    init(controller: breedsViewController,
         networkRequester: networkRequester) {

        self.controller = controller
        self.networkRequester = networkRequester

        self.requestBreeds()
    }

    public func requestBreeds() {
        networkRequester.requestBreeds(pageToRequest: 0) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(var breeds):

                for index in 0..<breeds.count {

                    RequestMaker().requestImageInformation(referenceId: breeds[index].reference_image_id) {[weak self] url in

                        guard let self else { return }

                        breeds[index].addImageUrl(url)
                        self.breeds = Set(breeds.map{$0})
                        self.controller?.didLoadBreeds()
                    }
                }

            case .failure(let error):
                print("Error, should handle")
            }
        }
    }
}
