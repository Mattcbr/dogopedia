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

    init(controller: breedsViewController?,
         networkRequester: networkRequester) {

        self.controller = controller
        self.networkRequester = networkRequester

        self.requestBreeds()
    }

    func didScrollToBottom() {

        requestBreeds()
    }

    func requestBreeds() {

        networkRequester.requestBreeds(requestType: .allBreeds(self.pageToRequest)) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(let resultBreeds):

                for index in 0..<resultBreeds.count {

                    if !self.breeds.contains(where: { $0.id == resultBreeds[index].id } ) {
                        self.breeds.append(resultBreeds[index])
                    }

                    if index == resultBreeds.count - 1 {
                        self.controller?.didLoadBreeds(wasSuccessful: true)
                        self.pageToRequest += 1
                    }

                    networkRequester.requestImageInformation(referenceId: resultBreeds[index].imageReference) {[weak self] data in

                        guard let self else { return }

                        if let breedIndex = self.breeds.firstIndex(of: resultBreeds[index]) {
                            self.breeds[breedIndex].addImageData(data)
                            self.controller?.didLoadImageForBreed(self.breeds[breedIndex])
                        }
                    }
                }

            case .failure(let error):
                self.controller?.didLoadBreeds(wasSuccessful: false)
                print("Error requesting breeds: \(error.localizedDescription)")
            }
        }
    }
}
