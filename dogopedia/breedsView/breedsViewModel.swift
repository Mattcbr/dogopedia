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

    var pageToRequest: Int = 0
    public var breeds: [Breed] = []

    init(controller: breedsViewController,
         networkRequester: networkRequester) {

        self.controller = controller
        self.networkRequester = networkRequester

        self.requestBreeds()
    }

    func didScrollToBottom() {

        self.pageToRequest += 1
        requestBreeds()
    }

    func requestBreeds() {

        networkRequester.requestBreeds(requestType: .allBreeds(self.pageToRequest)) { [weak self] result in

            guard let self else { return }

            var dogsWithImagesCounter: Int = 0

            switch result {
            case .success(var resultBreeds):

                for index in 0..<resultBreeds.count {

                    networkRequester.requestImageInformation(referenceId: resultBreeds[index].reference_image_id) {[weak self] url in

                        guard let self else { return }

                        resultBreeds[index].addImageUrl(url)
                        dogsWithImagesCounter += 1

                        if !self.breeds.contains(where: { $0.id == resultBreeds[index].id } ) {
                            self.breeds.append(resultBreeds[index])
                        }

                        if dogsWithImagesCounter == resultBreeds.count {
                            self.controller?.didLoadBreeds()
                        }
                    }
                }

            case .failure(let error):
                print("Error, should handle")
            }
        }
    }
}
