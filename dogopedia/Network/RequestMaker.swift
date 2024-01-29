//
//  RequestMaker.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation
import Alamofire
import AlamofireImage

protocol networkRequester {

    func requestBreeds(requestType: requestType, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void)
    func requestImageInformation(referenceId: String, completion: @escaping (String?) -> Void)
}

enum HttpRequestError: Error {
    case unavailable
    case decoding
}

enum requestType {
    case allBreeds(Int)
    case searchBreeds(String)
}

class RequestMaker: networkRequester {

    func requestBreeds(requestType: requestType, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void) {

        var endpoint: URL?

        switch requestType {
        case let .allBreeds(pageNumber):
            endpoint = UrlBuilder.buildMainScreenUrl(page: pageNumber)

        case let .searchBreeds(searchQuery):
            endpoint = UrlBuilder.buildSearchUrl(searchQuery: searchQuery)
        }

        if let endpoint {
            getRequestForURL(endpoint) { result in
                completion(result)
            }
        }
    }

    func requestImageInformation(referenceId: String, completion: @escaping (String?) -> Void) {

        guard let endpointForImages = UrlBuilder.buildImageUrl(referenceId: referenceId) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: endpointForImages) { data, _, error in

            if let data = data {

                do {
                    let dataAsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let url = dataAsDict?["url"] as? String
                    completion(url)
                } catch {
                    print("Image Request Failed for :\(referenceId)")
                    completion(nil)
                }
            } else if let error = error {
                print("Image Request Failed with error: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }

    private func getRequestForURL<T>(_ requestUrl: URL, _ completion: @escaping (Swift.Result<T, HttpRequestError>) -> Void) where T : Codable {

        let task = URLSession.shared.dataTask(with: requestUrl) { data, _, error in

            guard let data,
                  error == nil else {

                completion(.failure(.unavailable))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))

            } catch {

                print("RequestMaker Error: \(error.localizedDescription)")
                completion(.failure(.unavailable))
            }
        }

        task.resume()
    }
}
