//
//  breedsViewModel.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

class breedsViewModel {
    
    weak var controller: breedsViewController?
    let networkRequestManager: networkRequestManager
    let databaseManager: dbManager

    var pageToRequest: Int = 0
    @Published var breeds: [Breed] = []

    var gotBreedsFromDatabase = false
    var gotBreedsFromNetwork = false
    var isRequestingBreeds = false

    init(controller: breedsViewController?,
         networkRequestManager: networkRequestManager) {

        self.controller = controller
        self.networkRequestManager = networkRequestManager
        self.databaseManager = dbManager.shared

        self.requestBreedsFromDatabase()
        Task {
            await self.requestBreedsFromNetwork()
        }
    }

    func requestMoreIfNeeded(breed: Breed) {

        guard !isRequestingBreeds,
              let breedIndex = breeds.firstIndex(of: breed),
              breedIndex >= breeds.count - 5 else { return }

        Task {
            await requestBreedsFromNetwork()
        }
    }

    func requestBreedsFromDatabase() {

        let myBreeds = databaseManager.breeds.map({$0.toBreed()})

        gotBreedsFromDatabase = true

        for index in 0..<myBreeds.count {

            if !self.breeds.contains(where: { $0.id == myBreeds[index].id } ) {
                self.breeds.append(myBreeds[index])
            }

            if index == myBreeds.count - 1 {
                self.controller?.didLoadBreeds(wasSuccessful: true,
                                               fromNetworkRequest: false)
                self.showHelperLabelIfNeeded()
            }
        }
    }

    @MainActor
    private func requestBreedsFromNetwork() async {

        self.isRequestingBreeds = true

        let result = await networkRequestManager.requestBreeds(requestType: .allBreeds(self.pageToRequest))

        self.gotBreedsFromNetwork = true

        switch result {
        case .success(let resultBreeds):

            for index in 0..<resultBreeds.count {

                if !self.breeds.contains(where: { $0.id == resultBreeds[index].id } ) {

                    self.breeds.append(resultBreeds[index])

                    let breedImageURL = await networkRequestManager.requestImageInformation(referenceId: resultBreeds[index].imageReference)

                    if let breedIndex = self.breeds.firstIndex(of: resultBreeds[index]) {
                        self.breeds[breedIndex].addImageUrl(breedImageURL)
                    }
                }

                if index == resultBreeds.count - 1 {
                    self.pageToRequest += 1
                }
            }

        case .failure(let error):
            print("Error requesting breeds: \(error.localizedDescription)")
        }

        self.isRequestingBreeds = false
    }

    private func showHelperLabelIfNeeded() {

        if self.gotBreedsFromDatabase && self.gotBreedsFromNetwork && self.breeds.count == 0 {
            self.controller?.showHelperLabel()
        }
    }
}
