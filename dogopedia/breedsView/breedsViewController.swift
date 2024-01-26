//
//  breedsViewController.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import UIKit

class breedsViewController: UICollectionViewController {

    var model: breedsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.model = breedsViewModel(controller: self)
    }

}
