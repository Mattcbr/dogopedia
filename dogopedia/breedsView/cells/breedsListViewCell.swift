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

        guard let imageUrl = breed.imageUrl, let url = URL(string: imageUrl) else { return }
        
        breedImageView.af.setImage(withURL: url)
        breedImageView.contentMode = .scaleAspectFill
        breedNameLabel.text = breed.name
    }
}
