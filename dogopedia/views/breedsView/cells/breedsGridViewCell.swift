//
//  breedsGridViewCell.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 27/01/2024.
//

import UIKit

class breedsGridViewCell: UICollectionViewCell {

    @IBOutlet weak var breedImageView: UIImageView!
    @IBOutlet weak var breedNameLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var breedId: Int?

    func setupForBreed(_ breed: Breed) {

        if breed.hasLoadedImageData {
            if let imageData = breed.imageData {
                breedImageView.image = UIImage(data: imageData)

            } else {
                breedImageView.image = UIImage(named: "notfound")
            }

            loadingIndicator.stopAnimating()

            if self.breedImageView.alpha != 1 {
                UIView.animate(withDuration: 0.5) {
                    self.breedImageView.alpha = 1
                }
            }
        } else {
            loadingIndicator.startAnimating()
            loadingIndicator.hidesWhenStopped = true
            breedImageView.alpha = 0
        }

        breedImageView.contentMode = .scaleAspectFill
        breedNameLabel.text = breed.name
        breedId = breed.id
    }
}
