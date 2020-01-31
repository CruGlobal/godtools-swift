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
    
    @IBOutlet weak private var backgroundViewContainer: UIView!
    @IBOutlet weak private var backgroundImageView: UIImageView!
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        for subview in backgroundViewContainer.subviews {
            subview.removeFromSuperview()
        }
        backgroundImageView.image = nil
    }
    
    func configure(viewModel: OnboardingTutorialBackgroundCellViewModel) {
        
        backgroundImageView.image = viewModel.backgroundImage
        
        if let customBackgroundView = viewModel.backgroundView {
            backgroundViewContainer.addSubview(customBackgroundView)
            customBackgroundView.constrainEdgesToSuperview()
        }
    }
}
