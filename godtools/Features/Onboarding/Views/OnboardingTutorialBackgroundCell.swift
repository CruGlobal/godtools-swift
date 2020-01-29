//
//  OnboardingTutorialBackgroundCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialBackgroundCell: UICollectionViewCell {
    
    static let nibName: String = "OnboardingTutorialBackgroundCell"
    static let reuseIdentifier: String = "OnboardingTutorialBackgroundCellReuseIdentifier"
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    
    func configure(viewModel: OnboardingTutorialBackgroundCellViewModel) {
        backgroundImageView.image = viewModel.backgroundImage
    }
}
