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
    @IBOutlet weak var helperLabel: UILabel!
    
    var model: breedsViewModel?
    var isSorting = false
    var isRequesting = false
    let gridReuseId = "gridCell"
    let listReuseId = "listCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.model = breedsViewModel(controller: self, networkRequester: RequestMaker())

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.navBar.delegate = self
        self.setupNavbarItem()
        self.helperLabel.isHidden = true
    }

    // MARK: Public functions

    public func didLoadBreeds(wasSuccessful: Bool, fromNetworkRequest: Bool) {

        if fromNetworkRequest {
            self.isRequesting = false
        }

        if wasSuccessful {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
        }
    }

    /**
     This should be called when the async request for the breed's image is finished

     This function searches if the breed is being shown in any of the visible cells and refreshes the cell if needed

     - Parameter breed: The breed for which the image was loaded
     */
    public func didLoadImageForBreed(_ breed: Breed) {

        DispatchQueue.main.async {
            switch self.displaySelector.selectedSegmentIndex {
            case 0:

                if let cells = self.collectionView.visibleCells as? [breedsGridViewCell],
                   let cell = cells.first(where: {$0.breedId == breed.id}),
                   let indexPath = self.collectionView.indexPath(for: cell){

                    self.collectionView.reloadItems(at: [indexPath])
                }
            case 1:
                if let cells = self.tableView.visibleCells as? [breedsListViewCell],
                   let cell = cells.first(where: {$0.breedId == breed.id}),
                   let indexPath = self.tableView.indexPath(for: cell){

                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            default:
                break
            }
        }
    }

    public func showHelperLabel() {

        self.helperLabel.text = "To see breeds here you need to add them to your favorites when you're online"
        self.helperLabel.isHidden = false
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

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let destinationVC = segue.destination as? detailsViewController else { return }

        var breed: Breed?
        var selectedCellIndexPath: Int?

        if let gridCell = sender as? breedsGridViewCell {
            selectedCellIndexPath = self.collectionView.indexPath(for: gridCell)?.row

        } else if let listCell = sender as? breedsListViewCell {
            selectedCellIndexPath = self.tableView.indexPath(for: listCell)?.row
        }

        if let selectedCellIndexPath {
            breed = getBreedsArray()[selectedCellIndexPath]

            destinationVC.breed = breed
        }
    }

    // MARK: Helper functions

    /**
     This function gets the array of breeds and sorts it if needed

     - Returns: An array of breeds
     */
    func getBreedsArray() -> [Breed] {
        guard let model else { return [] }
        
        var breedsArray = model.breeds

        if self.isSorting {
            breedsArray.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }

        return breedsArray
    }

    // MARK: Continuous Scroll

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y

        let diff = scrollContentSizeHeight - scrollOffset - scrollViewHeight

        if (diff <= 400 && !self.isRequesting) {
            self.isRequesting = true
            model?.didScrollToBottom()
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

        let breedsArray = getBreedsArray()

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

        let breedsArray = getBreedsArray()

        cell.setupForBreed(breedsArray[indexPath.row])
        cell.selectionStyle = .none

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

        if self.displaySelector.selectedSegmentIndex == 0 {
            self.collectionView.reloadData()
        } else {
            self.tableView.reloadData()
        }
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {

     return .topAttached
    }
}
