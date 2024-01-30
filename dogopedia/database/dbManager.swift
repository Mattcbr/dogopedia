//
//  dbManager.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 30/01/2024.
//

import Foundation
import RealmSwift

class dbManager: Observable {

    @Published var breeds: [databaseBreed] = []

    static let shared = dbManager()

    private init() {
        updateBreeds()
    }

    private func updateBreeds() {
        do {
            let realm = try Realm()
            let dbBreeds = realm.objects(databaseBreed.self)

            self.breeds = dbBreeds.map(databaseBreed.init)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func addBreed(breed: Breed) {

        let dbBreed = databaseBreed.fromBreed(breed)
        guard !self.breeds.contains(dbBreed) else {return}

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(dbBreed)
                self.updateBreeds()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func removeBreed(id: Int) {
        do {
            let realm = try Realm()
            guard let breed = realm.object(ofType: databaseBreed.self, forPrimaryKey: id) else { return }
            try realm.write {
                realm.delete(breed)
                self.updateBreeds()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
