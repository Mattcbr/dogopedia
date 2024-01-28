//
//  breedsListViewCell.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 27/01/2024.
//

import UIKit

class breedsListViewCell: UITableViewCell {

    @IBOutlet weak var breedNameLabel: UILabel!
    @IBOutlet weak var breedImageView: UIImageView!

    func setupForBreed(_ breed: Breed) {

        if let imageUrl = breed.imageUrl, let url = URL(string: imageUrl) {
            breedImageView.af.setImage(withURL: url)

        } else {
            breedImageView.image = UIImage(named: "notfound")
        }

        breedImageView.contentMode = .scaleAspectFill
        breedNameLabel.text = breed.name
    }
}
