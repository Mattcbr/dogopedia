//
//  searchViewModel.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 28/01/2024.
//

import Foundation

class searchViewModel {

    let controller: searchViewController?
    let networkRequester: networkRequester
    public var resultBreeds: Set<Breed> = []

    init(controller: searchViewController?,
         networkRequester: networkRequester) {

        self.controller = controller
        self.networkRequester = networkRequester
    }

    func performSearch(withTerm term: String, completion: @escaping(viewState) -> Void) {
        networkRequester.searchBreeds(searchQuery: term) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(var breeds):

                guard breeds.count > 0 else {
                    completion(.error)
                    return
                }

                for index in 0..<breeds.count {

                    networkRequester.requestImageInformation(referenceId: breeds[index].reference_image_id) { url in
                        breeds[index].addImageUrl(url)
                        self.resultBreeds = Set(breeds.map{$0})

                        if index == breeds.count - 1 {
                            completion(.successful)
                        }
                    }
                }
            case .failure:
                completion(.error)
            }
        }
    }
}
