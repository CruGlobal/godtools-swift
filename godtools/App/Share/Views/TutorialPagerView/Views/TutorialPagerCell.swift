//
//  TutorialPagerCell.swift
//  godtools
//
//  Created by Robert Eldredge on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Lottie

class TutorialPagerCell: UICollectionViewCell {
    
    static let nibName = "TutorialPagerCell"
    static let reuseIdentifier = "TutorialPagerCellReuseIdentifier"
    
    private var viewModel: TutorialPagerCellViewModelType?
    private var customView: UIView?
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var animationView: AnimationView!
    @IBOutlet weak private var customContentView: UIView!
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        messageLabel.text = nil
        animationView.stop()
        animationView.animation = nil
        customView?.removeFromSuperview()
        customView = nil
        viewModel = nil
    }
    
    func configure(viewModel: TutorialPagerCellViewModelType) {
        
        self.viewModel = viewModel
        
        if viewModel.customView != nil {
            
            renderCustomContentView()
            hideMainViews()
        } else {
            
            renderMainViews()
            hideCustomContentView()
        }
    }
    
    private func hideMainViews() {
        
        //labels
        titleLabel.isHidden = true
        messageLabel.isHidden = true
        
        //mainImage
        imageView.image = nil
        imageView.isHidden = true
        
        //animation
        animationView.stop()
        animationView.isHidden = true
    }
    
    private func hideCustomContentView() {
        
        customView?.removeFromSuperview()
        self.customView = nil
        customContentView.isHidden = true
    }
    
    private func renderMainViews() {
        
        guard let viewModel = self.viewModel else { return }
        
        //labels
        titleLabel.text = viewModel.title
        titleLabel.isHidden = false
        messageLabel.text = viewModel.message
        messageLabel.isHidden = false
        messageLabel.setLineSpacing(lineSpacing: 2)
        
        //mainImage
        if let imageName = viewModel.mainImageName, !imageName.isEmpty, let mainImage = UIImage(named: imageName) {
            imageView.image = mainImage
            imageView.isHidden = false
        }
        
        //animation
        if let animationName = viewModel.animationName, !animationName.isEmpty {
            let animation = Animation.named(animationName)
            animationView.animation = animation
            animationView.loopMode = .loop
            animationView.play()
            animationView.isHidden = false
        }
    }
    
    private func renderCustomContentView() {
        
        guard let viewModel = self.viewModel else { return }
        
        self.customView = viewModel.customView
        
        guard let view = self.customView else { return }
        
        customContentView.addSubview(view)
        customContentView.isHidden = false
    }
    
}
