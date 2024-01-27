//
//  breedsViewController.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import UIKit

class breedsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displaySelector: UISegmentedControl!
    @IBOutlet weak var navBar: UINavigationBar!

    var model: breedsViewModel?
    let gridReuseId = "gridCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.model = breedsViewModel(controller: self)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    // MARK: Public functions

    public func didLoadBreeds() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: Segmented Control

    @IBAction func indexChanged(_ sender: Any) {

        switch displaySelector.selectedSegmentIndex {
        case 0:
            tableView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        case 1:
            collectionView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        default:
            break
        }
    }
}

// MARK: Collection View

extension breedsViewController: UICollectionViewDelegate & UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.breeds.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let model, model.breeds.count > indexPath.row, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridReuseId, for: indexPath) as? breedsGridViewCell else { return UICollectionViewCell() }

        cell.setupForBreed(Array(model.breeds)[indexPath.row])

        return cell
    }
}
