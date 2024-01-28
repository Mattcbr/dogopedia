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
    func requestBreeds(pageToRequest: Int, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void)
    func searchBreeds(searchQuery: String, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void)
    func requestImageInformation(referenceId: String, completion: @escaping (String?) -> Void)
}

enum HttpRequestError: Error {
    case unavailable
    case decoding
}

class RequestMaker: networkRequester {

    func requestBreeds(pageToRequest: Int, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void) {

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PERSONAL_API_KEY") as? String else { return }

        let endpointForBreeds = "https://api.thedogapi.com/v1/breeds?api_key=\(apiKey)&limit=20&page=\(pageToRequest)"

        getRequestForURL(endpointForBreeds) { result in
            completion(result)
        }
    }

    func searchBreeds(searchQuery: String, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void) {

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PERSONAL_API_KEY") as? String else { return }

        let endpointForBreeds = "https://api.thedogapi.com/v1/breeds/search?q=\(searchQuery)"

        getRequestForURL(endpointForBreeds) { result in
            completion(result)
        }
    }


    func requestImageInformation(referenceId: String, completion: @escaping (String?) -> Void) {

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PERSONAL_API_KEY") as? String,
              let endpointForImages = URL(string: "https://api.thedogapi.com/v1/images/\(referenceId)?api_key=\(apiKey)") else {
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
                    print("HTTP Request Failed")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }

        task.resume()
    }

    private func getRequestForURL<T>(_ requestUrl: String, _ completion: @escaping (Swift.Result<T, HttpRequestError>) -> Void) where T : Codable {

        Alamofire.AF.request(requestUrl).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))

            case .failure(let error):
                print("RequestMaker Error: \(error.localizedDescription)")
                completion(.failure(.unavailable))
            }
        }
    }
}
