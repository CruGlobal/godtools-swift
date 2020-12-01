//
//  LearnToShareToolCell.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import Lottie

class LearnToShareToolCell: UICollectionViewCell {
    
    static let nibName: String = "LearnToShareToolCell"
    static let reuseIdentifier: String = "LearnToShareToolCellReuseIdentifier"
    
    private var viewModel: LearnToShareToolCellViewModelType?
    
    @IBOutlet weak private var featuredImageView: UIImageView!
    @IBOutlet weak private var animationView: AnimationView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageTextView: UITextView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        featuredImageView.image = nil
        animationView.stop()
        animationView.animation = nil
    }
    
    func configure(viewModel: LearnToShareToolCellViewModelType) {
        
        self.viewModel = viewModel
                
        if let imageName = viewModel.imageName {
            featuredImageView.image = UIImage(named: imageName)
            featuredImageView.isHidden = false
        }
        else {
            featuredImageView.image = nil
            featuredImageView.isHidden = true
        }
        
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
        
        titleLabel.text = viewModel.title
        titleLabel.setLineSpacing(lineSpacing: 1)
        titleLabel.textAlignment = .center
        
        messageTextView.text = viewModel.message
        messageTextView.setLineSpacing(lineSpacing: 5)
        messageTextView.textAlignment = .center
    }
}
