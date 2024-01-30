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

        networkRequestManager.requestBreeds(requestType: .searchBreeds(term)) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(var breeds):

                guard breeds.count > 0 else {
                    completion(.error)
                    return
                }

                let dispatchGroup = DispatchGroup()

                for index in 0..<breeds.count {

                    dispatchGroup.enter()
                    networkRequestManager.requestImageInformation(referenceId: breeds[index].imageReference) { data in
                        breeds[index].addImageData(data)
                        self.resultBreeds = Set(breeds.map{$0})
                        dispatchGroup.leave()
                    }

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
