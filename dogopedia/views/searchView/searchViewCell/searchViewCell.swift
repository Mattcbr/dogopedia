//
//  searchViewCell.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 28/01/2024.
//

import UIKit

class searchViewCell: UITableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!

    func setupForBreed(_ breed: Breed) {

        titleLabel.text = breed.name
        groupLabel.text = "Group: \(breed.group ?? "Unknown")"
        originLabel.text = "Origin: \(breed.origin ?? "Unknown")"
    }
}
