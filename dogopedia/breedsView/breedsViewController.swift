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
    @IBOutlet weak var navBarRightButton: UIBarButtonItem!
    
    var model: breedsViewModel?
    var isSorting = false
    let gridReuseId = "gridCell"
    let listReuseId = "listCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.model = breedsViewModel(controller: self)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.navBar.delegate = self
        self.setupNavbarItem()
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
        
        guard let model,
              model.breeds.count > indexPath.row,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridReuseId, for: indexPath) as? breedsGridViewCell
              else { return UICollectionViewCell() }

        var breedsArray = Array(model.breeds)

        if self.isSorting {
            breedsArray.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }

        cell.setupForBreed(breedsArray[indexPath.row])

        return cell
    }
}

// MARK: Table View

extension breedsViewController: UITableViewDelegate & UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.breeds.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let model,
              model.breeds.count > indexPath.row,
              let cell = tableView.dequeueReusableCell(withIdentifier: listReuseId, for: indexPath) as? breedsListViewCell
             else { return UITableViewCell() }

        var breedsArray = Array(model.breeds)

        if self.isSorting {
            breedsArray.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }

        cell.setupForBreed(breedsArray[indexPath.row])

        return cell
    }
}

// MARK: Navigation Bar

extension breedsViewController: UINavigationBarDelegate {

    func setupNavbarItem() {

        self.navBarRightButton.title = self.isSorting ? "Unsort" : "Sort"
        self.navBarRightButton.action = #selector(didTapNavBarItem)
    }

    @objc
    func didTapNavBarItem() {

        self.isSorting.toggle()
        self.setupNavbarItem()
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {

     return .topAttached
    }
}
