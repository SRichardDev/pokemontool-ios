//
//  GymDetailAnnotationView.swift
//  PokemapTool
//
//  Created by Nico on 27.02.18.
//  Copyright © 2018 NST. All rights reserved.
//

import UIKit

class PokestopDetailAnnotationView: UIView {
    
    @IBOutlet weak var pokestopImageView: UIImageView!
    @IBOutlet weak var pokestopNameLabel: UILabel!
    @IBOutlet weak var pokestopInfoLabel: UILabel!
    
    var pokestop: Pokestop!
    var raidDetails: [String] = []
    weak var delegate: PokestopDetailDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
    }
    
    func configure(with pokestop: Pokestop) {
        self.pokestop = pokestop
        pokestopNameLabel.text = pokestop.name
        pokestopImageView.image = UIImage(named: "Pokestop")
    }
    
    @IBAction func showPokestopInfoTapped(_ sender: Any) {
        delegate?.showDetail(for: pokestop)
    }
}
