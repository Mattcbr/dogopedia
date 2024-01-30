//
//  detailsViewController.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 27/01/2024.
//

import UIKit

class detailsViewController: UIViewController {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var temperamentLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    public var breed: Breed?
    var viewModel: detailsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = detailsViewModel(controller: self)
        self.setupForBreed()
    }

    func setupForBreed() {
        guard let breed = self.breed else { return }

        if let imageData = breed.imageData {
            headerImageView.image = UIImage(data: imageData)

        } else {
            self.headerImageView.image = UIImage(named: "notfound")
        }

        self.headerImageView.contentMode = .scaleAspectFill
        self.titleLabel.text = breed.name
        self.categoryLabel.text = "Category: \(breed.group ?? "Unknown")"
        self.originLabel.text = "Origin: \(breed.origin ?? "Unknown")"
        self.temperamentLabel.text = "Temperament:\(breed.temperament ?? "Unknown")"

        setupFavButton()
    }

    // Favorite Button

    public func setupFavButton() {
        guard let breed = self.breed else { return }

        let isFavorite = self.viewModel?.isFavorite(breedId: breed.id) ?? false
        let buttonImage = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        let buttonText = isFavorite ? "Remove from favorites" : "Add to favorites"

        self.favoriteButton.setImage(buttonImage, for: .normal)
        self.favoriteButton.setTitle(buttonText, for: .normal)
    }

    @IBAction func didPressFavoriteButton(_ sender: Any) {

        guard let breed = self.breed else { return }

        self.viewModel?.didPressFavoriteButton(forBreed: breed)
    }
}
