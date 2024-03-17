//
//  breedsViewModel.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

enum breedsViewState {

    case loading
    case success
    case initialLoading
    case error
}

class breedsViewModel: ObservableObject {

    let networkRequestManager: networkRequestManager
    let databaseManager: dbManager

    var pageToRequest: Int = 0
    @Published var breeds: [Breed] = []
    @Published var state: breedsViewState

    var gotBreedsFromDatabase = false
    var gotBreedsFromNetwork = false

    init(requestManager: networkRequestManager,
         databaseManager: dbManager) {

        self.networkRequestManager = requestManager
        self.databaseManager = databaseManager
        self.state = .initialLoading

        self.requestBreedsFromDatabase()
        Task {
            await self.requestBreedsFromNetwork()
        }
    }

    func requestMoreIfNeeded(breed: Breed) {

        guard state != .loading,
              state != .initialLoading,
              let breedIndex = breeds.firstIndex(of: breed),
              breedIndex >= breeds.count - 5 else { return }

        Task {
            await requestBreedsFromNetwork()
        }
    }

    private func requestBreedsFromDatabase() {

        if state != .initialLoading {
            state = .loading
        }

        let myBreeds = databaseManager.breeds.map({$0.toBreed()})

        gotBreedsFromDatabase = true

        for index in 0..<myBreeds.count {

            if !self.breeds.contains(where: { $0.id == myBreeds[index].id } ) {
                self.breeds.append(myBreeds[index])
            }

            if index == myBreeds.count - 1 {
                self.checkForErrorState()
            }
        }
    }

    @MainActor
    private func requestBreedsFromNetwork() async {

        if state != .initialLoading {
            state = .loading
        }

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
                    self.state = .success
                    self.pageToRequest += 1
                }
            }

        case .failure(let error):
            self.checkForErrorState()
            print("Error requesting breeds: \(error.localizedDescription)")
        }
    }

    private func checkForErrorState() {

        if self.gotBreedsFromDatabase && self.gotBreedsFromNetwork && self.breeds.count == 0 {
            self.state = .error
        }
    }
}
