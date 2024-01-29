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

    public var breed: Breed?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupForBreed()
    }

    func setupForBreed() {
        guard let breed = self.breed else { return }

        if let imageUrl = breed.imageUrl, let url = URL(string: imageUrl) {

            self.headerImageView.af.setImage(withURL: url)
        } else {
            self.headerImageView.image = UIImage(named: "notfound")
        }

        self.headerImageView.contentMode = .scaleAspectFill
        self.titleLabel.text = breed.name
        self.categoryLabel.text = "Category: \(breed.breed_group ?? "Unknown")"
        self.originLabel.text = "Origin: \(breed.origin ?? "Unknown")"
        self.temperamentLabel.text = "Temperament:\(breed.temperament ?? "Unknown")"
    }
}
