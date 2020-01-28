//
//  MainOnboardingTutorialCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MainOnboardingTutorialCell: UICollectionViewCell {
    
    static let nibName: String = "MainOnboardingTutorialCell"
    static let reuseIdentifier: String = "MainOnboardingTutorialCellReuseIdentifier"
    
    @IBOutlet weak private var mainImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    
    func configure(viewModel: MainOnboardingTutorialCellViewModel) {
        mainImageView.image = viewModel.mainImage
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
    }
}
