//
//  GlobalActivityCell.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class GlobalActivityCell: UICollectionViewCell {
    
    static let nibName: String = "GlobalActivityCell"
    static let reuseIdentifier: String = "GlobalActivityCellReuseIdentifier"
    
    @IBOutlet weak private var countLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    private func setupLayout() {
        
        //drawShadow
        backgroundColor = UIColor.white
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        clipsToBounds = false
        layer.cornerRadius = 10
    }
    
    func configure(viewModel: GlobalActivityCellViewModel) {
        countLabel.text = viewModel.count
        titleLabel.text = viewModel.title
    }
}
