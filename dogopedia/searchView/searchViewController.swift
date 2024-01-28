//
//  searchViewController.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 28/01/2024.
//

import UIKit

enum viewState {
    case waiting
    case loading
    case successful
    case error
}

class searchViewController: UIViewController {

    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var model: searchViewModel?
    var searchTimer: Timer?
    let searchCellReuseId = "searchCell"
    var state: viewState = .waiting {
        didSet {
            didChangeState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.model = searchViewModel(controller: self, networkRequester: RequestMaker())

        self.state = .waiting
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    // MARK: State Observer

    func didChangeState() {

        switch self.state {
        case .waiting:
            helperLabel.text = "Here you can search for any dog breed you want!"
            helperLabel.isHidden = false
            self.tableView.isHidden = true

        case .loading:
            helperLabel.text = "We're fetching answers for you..."
            helperLabel.isHidden = false
            self.tableView.isHidden = true

        case .successful:
            DispatchQueue.main.async {
                self.helperLabel.isHidden = true
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }

        case .error:
            helperLabel.text = "Sorry, we couldn't fetch anything for you..."
            helperLabel.isHidden = false
            self.tableView.isHidden = true
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let destinationVC = segue.destination as? detailsViewController,
              let model = self.model,
              let searchCell = sender as? searchViewCell,
              let selectedCellIndexPath = self.tableView.indexPath(for: searchCell)?.row else { return }

        let breed = Array(model.resultBreeds)[selectedCellIndexPath]
        destinationVC.breed = breed
    }
}

// Mark: Table View

extension searchViewController: UITableViewDelegate & UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.resultBreeds.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let model,
              model.resultBreeds.count > indexPath.row,
              let cell = tableView.dequeueReusableCell(withIdentifier: searchCellReuseId, for: indexPath) as? searchViewCell
              else { return UITableViewCell() }

        let breedsArray = Array(model.resultBreeds)

        cell.setupForBreed(breedsArray[indexPath.row])

        return cell
    }
}

// MARK: Search Bar

extension searchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.searchTimer?.invalidate()

        guard searchText.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            state = .waiting
            return
        }

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] timer in

            guard let self = self else { return }

            if self.state != .successful {
                self.state = .loading
            }

            self.model?.performSearch(withTerm: searchText) { resultState in
                self.state = resultState
            }
        })
    }
}
