//
//  mockRequestMaker.swift
//  dogopediaTests
//
//  Created by Matheus Queiroz on 29/01/2024.
//

import Foundation

@testable import dogopedia

class mockRequestMaker: networkRequester {

    var requestedPage: Int?
    var requestedTerm: String?
    var didRequestImageInformation: Bool = false
    var breedsToReturn: [Breed] = []

    func requestBreeds(requestType: dogopedia.requestType, completion: @escaping (Result<[dogopedia.Breed], dogopedia.HttpRequestError>) -> Void) {

        switch requestType {
        case let .allBreeds(page):
            requestedPage = page
            
        case let .searchBreeds(searchQuery):
            requestedTerm = searchQuery
        }

        completion(.success(breedsToReturn))
    }

    func requestImageInformation(referenceId: String, completion: @escaping (String?) -> Void) {
        didRequestImageInformation = true
        completion(nil)
    }
}
