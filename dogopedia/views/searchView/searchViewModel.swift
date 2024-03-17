//
//  searchViewModel.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 28/01/2024.
//

import Foundation

class searchViewModel {

    weak var controller: searchViewController?
    let networkRequestManager: networkRequestManager
    public var resultBreeds: Set<Breed> = []

    init(controller: searchViewController?,
         networkRequestManager: networkRequestManager) {

        self.controller = controller
        self.networkRequestManager = networkRequestManager
    }

    func performSearch(withTerm term: String, completion: @escaping(viewState) -> Void) {

        Task {

            let result = await networkRequestManager.requestBreeds(requestType: .searchBreeds(term))

            switch result {
            case .success(var breeds):

                guard breeds.count > 0 else {
                    completion(.error)
                    return
                }

                let dispatchGroup = DispatchGroup()

                for index in 0..<breeds.count {

                    dispatchGroup.enter()

                    let breedImageURL = await networkRequestManager.requestImageInformation(referenceId: breeds[index].imageReference)
                    breeds[index].addImageUrl(breedImageURL)
                    self.resultBreeds = Set(breeds.map{$0})
                    dispatchGroup.leave()

                    dispatchGroup.notify(queue: .main) {
                        completion(.successful)
                    }
                }
            case .failure:
                completion(.error)
            }
        }
    }
}
