//
//  UrlBuilder.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 28/01/2024.
//

import Foundation

enum UrlBuilder {

    static func buildMainScreenUrl(page: Int) -> URL? {

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PERSONAL_API_KEY") as? String else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.thedogapi.com"
        components.path = "/v1/breeds"
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        return components.url!
    }

    static func buildSearchUrl(searchQuery: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.thedogapi.com"
        components.path = "/v1/breeds/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: searchQuery)
        ]

        return components.url!
    }
}
