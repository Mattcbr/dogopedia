//
//  RequestManager.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

protocol networkRequestManager {

    func requestBreeds(requestType: requestType) async -> Swift.Result<[Breed], HttpRequestError>
    func requestImageInformation(referenceId: String) async -> URL?
}

enum HttpRequestError: Error {
    case unavailable
    case decoding
}

enum requestType {
    case allBreeds(Int)
    case searchBreeds(String)
}

class RequestManager: networkRequestManager {

    /**
     This function gets breeds from the API

     - Parameter requestType: The type of request to be performed (All or search)
     - Returns: A swift result where if successful it will contain an array of `Breed`, if failure contains an `HttpRequestError`
     */
    func requestBreeds(requestType: requestType) async -> Swift.Result<[Breed], HttpRequestError> {

        var endpoint: URL?

        switch requestType {
        case let .allBreeds(pageNumber):
            endpoint = UrlBuilder.buildMainScreenUrl(page: pageNumber)

        case let .searchBreeds(searchQuery):
            endpoint = UrlBuilder.buildSearchUrl(searchQuery: searchQuery)
        }

        guard let endpoint else { return .failure(.unavailable) }

        return await getRequestForURL(endpoint)
    }

    /**
     This function returns an URL for the breed image

     Since it is necessary to perform a second request to get the breed image's URL, and most of the information that comes on this second request is not being used right now, this function makes the request and returns a string with only the URL for the breed's image.

     - Parameter referenceId: The reference that should be used to make a request
     - Returns: An optional `URL` for the breed's image
     */
    func requestImageInformation(referenceId: String) async -> URL? {

        guard let endpointForImages = UrlBuilder.buildImageUrl(referenceId: referenceId) else { return nil }

        do {

            let (data, _) = try await URLSession.shared.data(from: endpointForImages)
            let dataAsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            guard let urlString = dataAsDict?["url"] as? String,
                  let url = URL(string: urlString) else {
                return nil
            }

            return url
        } catch {
            print("Image Request Failed for :\(referenceId)")
            return nil
        }
    }

    private func getRequestForURL<T: Codable>(_ requestUrl: URL) async -> Result<T, HttpRequestError> {

        do {
            let (data, _) = try await URLSession.shared.data(from: requestUrl)
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedResponse)
        } catch {
            print("RequestManager Error: \(error.localizedDescription)")
            return .failure(.unavailable)
        }
    }
}
