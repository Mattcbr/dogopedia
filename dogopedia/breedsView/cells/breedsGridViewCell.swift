//
//  breedsGridViewCell.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 27/01/2024.
//

import UIKit
import AlamofireImage

class breedsGridViewCell: UICollectionViewCell {

    @IBOutlet weak var breedImageView: UIImageView!
    @IBOutlet weak var breedNameLabel: UILabel!
    
    func setupForBreed(_ breed: Breed) {
        
        guard let imageUrl = breed.imageUrl, let url = URL(string: imageUrl) else { return }

        breedImageView.af.setImage(withURL: url)
        breedNameLabel.text = breed.name

    }
}
