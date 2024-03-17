//
//  dogopediaApp.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 02/03/2024.
//

import SwiftUI

@main
struct dogopediaApp: App {
    let viewController = breedsViewController()
    var body: some Scene {
        WindowGroup {
            let networkManager = RequestManager.shared
            let dbManager = dbManager.shared
            viewController.environmentObject(breedsViewModel(requestManager: networkManager, databaseManager: dbManager))
        }
    }
}
