//
//  RequestMaker.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import Foundation
import Alamofire
import AlamofireImage

enum HttpRequestError: Error {
    case unavailable
    case decoding
}

class RequestMaker {

    var delegate: requestDelegate?

    public func requestBreeds(pageToRequest: Int, completion: @escaping (Swift.Result<[Breed], HttpRequestError>) -> Void) {

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PERSONAL_API_KEY") as? String else { return }

        let endpointForBreeds = "https://api.thedogapi.com/v1/breeds?api_key=\(apiKey)&limit=20&page=\(pageToRequest)"

        getRequestForURL(endpointForBreeds) { result in
            completion(result)
        }
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
