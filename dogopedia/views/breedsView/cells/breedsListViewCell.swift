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
    var breedId: Int?

    func setupForBreed(_ breed: Breed) {

        if breed.hasLoadedImageData {
            if let imageData = breed.imageData {
                breedImageView.image = UIImage(data: imageData)

            } else {
                breedImageView.image = UIImage(named: "notfound")
            }
        }

        breedImageView.contentMode = .scaleAspectFill
        breedNameLabel.text = breed.name
        breedId = breed.id
    }
}
