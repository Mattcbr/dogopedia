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
    public var breeds: [Breed] = []

    var gotBreedsFromDatabase = false
    var gotBreedsFromNetwork = false

    init(controller: breedsViewController?,
         networkRequestManager: networkRequestManager) {

        self.controller = controller
        self.networkRequestManager = networkRequestManager
        self.databaseManager = dbManager.shared

        self.requestBreedsFromDatabase()
        self.requestBreedsFromNetwork()
    }

    func didScrollToBottom() {

        requestBreedsFromNetwork()
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

    func requestBreedsFromNetwork() {

        networkRequestManager.requestBreeds(requestType: .allBreeds(self.pageToRequest)) { [weak self] result in

            guard let self else { return }

            self.gotBreedsFromNetwork = true

            switch result {
            case .success(let resultBreeds):

                for index in 0..<resultBreeds.count {

                    if !self.breeds.contains(where: { $0.id == resultBreeds[index].id } ) {
                        self.breeds.append(resultBreeds[index])

                        networkRequestManager.requestImageInformation(referenceId: resultBreeds[index].imageReference) {[weak self] data in

                            guard let self else { return }

                            if let breedIndex = self.breeds.firstIndex(of: resultBreeds[index]) {
                                self.breeds[breedIndex].addImageData(data)
                                self.controller?.didLoadImageForBreed(self.breeds[breedIndex])
                            }
                        }
                    }

                    if index == resultBreeds.count - 1 {
                        self.controller?.didLoadBreeds(wasSuccessful: true,
                                                       fromNetworkRequest: true)
                        self.showHelperLabelIfNeeded()
                        self.pageToRequest += 1
                    }
                }

            case .failure(let error):
                self.controller?.didLoadBreeds(wasSuccessful: false,
                                               fromNetworkRequest: true)
                self.showHelperLabelIfNeeded()
                print("Error requesting breeds: \(error.localizedDescription)")
            }
        }
    }

    private func showHelperLabelIfNeeded() {

        if self.gotBreedsFromDatabase && self.gotBreedsFromNetwork && self.breeds.count == 0 {
            self.controller?.showHelperLabel()
        }
    }
}
