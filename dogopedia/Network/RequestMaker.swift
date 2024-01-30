//
//  RequestMaker.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation

protocol networkRequester {

    func requestBreeds(requestType: requestType, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void)
    func requestImageInformation(referenceId: String, completion: @escaping (Data?) -> Void)
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

    /**
     This function gets breeds from the API

     - Parameter requestType: The type of request to be performed (All or search)
     - Parameter completion: the completionHandler to call when the work is done
     */
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

    /**
     This function returns an URL for the breed image

     Since it is necessary to perform a second request to get the breed image's URL, and most of the information that comes on this second request is not being used right now, this function makes the request and returns a string with only the URL for the breed's image.

     - Parameter referenceId: The reference that should be used to make a request
     - Parameter completion: the completionHandler to call when the work is done
     */
    func requestImageInformation(referenceId: String, completion: @escaping (Data?) -> Void) {

        guard let endpointForImages = UrlBuilder.buildImageUrl(referenceId: referenceId) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: endpointForImages) { data, _, error in

            if let data = data {

                do {
                    let dataAsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                    guard let urlString = dataAsDict?["url"] as? String,
                          let url = URL(string: urlString) else {
                        completion(nil)
                        return
                    }

                    URLSession.shared.dataTask(with: url) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(nil)
                            return
                        }
                        completion(data)
                    }.resume()
                } catch {
                    print("Image Request Failed for :\(referenceId)")
                    completion(nil)
                }
            } else if let error = error {
                print("Image Request Failed with error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    private func getRequestForURL<T>(_ requestUrl: URL, _ completion: @escaping (Swift.Result<T, HttpRequestError>) -> Void) where T : Codable {

        URLSession.shared.dataTask(with: requestUrl) { data, _, error in

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
        }.resume()
    }
}
