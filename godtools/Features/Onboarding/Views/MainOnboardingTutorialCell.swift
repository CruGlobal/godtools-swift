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
        mainImageView.image = nil
        animationView.stop()
        animationView.animation = nil
    }
    
    func configure(viewModel: MainOnboardingTutorialCellViewModel) {
        titleLabel.text = viewModel.title
        messageLabel.text = viewModel.message
        messageLabel.setLineSpacing(lineSpacing: 2)
        setMessageLabelHidden(hidden: viewModel.message.isEmpty)
        
        // mainImage
        if let mainImageName = viewModel.mainImageName, !mainImageName.isEmpty, let mainImage = UIImage(named: mainImageName) {
            self.mainImage = mainImage
            renderMainImage(mainImage: mainImage, mainImageView: nil)
            mainImageView.isHidden = false
        }
        else {
            mainImageView?.removeFromSuperview()
            mainImageView = nil
            mainImage = nil
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
    
    private func renderMainImage(mainImage: UIImage, mainImageView: UIImageView?) {
        let imageView: UIImageView = mainImageView ?? UIImageView()
        
        self.mainImage = mainImage
        self.mainImageView = imageView
        
        imageView.image = mainImage
        
        renderMedia(
            view: imageView,
            originalViewSize: mainImage.size
        )
    }
}
