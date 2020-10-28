//
//  MainOnboardingTutorialCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import Lottie

class MainOnboardingTutorialCell: UICollectionViewCell {
    
    static let nibName: String = "MainOnboardingTutorialCell"
    static let reuseIdentifier: String = "MainOnboardingTutorialCellReuseIdentifier"
    
    private var mainImage: UIImage?
    
    @IBOutlet weak private var mainImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var animationView: AnimationView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage = nil
        mainImageView.image = nil
        animationView.stop()
        animationView.animation = nil
    }
    
    func configure(viewModel: MainOnboardingTutorialCellViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
        
        // mainImage
        if let mainImageName = viewModel.mainImageName, !mainImageName.isEmpty, let mainImage = UIImage(named: mainImageName) {
            self.mainImage = mainImage
            mainImageView.image = mainImage
            mainImageView.isHidden = false
        }
        else {
            mainImage = nil
            mainImageView.image = nil
            mainImageView.isHidden = true
        }
        
        // animation
        if let animationName = viewModel.animationName, !animationName.isEmpty {
            let animation = Animation.named(animationName)
            animationView.animation = animation
            animationView.loopMode = .loop
            animationView.play()
            animationView.isHidden = false
        }
        else {
            animationView.stop()
            animationView.isHidden = true
        }
    }
}
