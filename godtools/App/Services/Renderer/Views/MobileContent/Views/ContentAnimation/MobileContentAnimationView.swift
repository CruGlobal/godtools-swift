//
//  MobileContentAnimationView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentAnimationView: MobileContentView {
    
    private let viewModel: MobileContentAnimationViewModel
    private let animatedView: AnimatedView = AnimatedView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    init(viewModel: MobileContentAnimationViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // animatedView
        addSubview(animatedView)
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        animatedView.constrainEdgesToView(view: self)
    }
    
    private func setupBinding() {
        
        if let animatedViewModel = viewModel.animatedViewModel {
            animatedView.configure(viewModel: animatedViewModel)
            animatedView.setAnimationContentMode(contentMode: .scaleAspectFill)
        }
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        
        let animationSize: CGSize
        
        if let animatedViewModel = viewModel.animatedViewModel, let assetSize = animatedViewModel.getAssetSize() {
            animationSize = assetSize
        }
        else {
            animationSize = CGSize(width: bounds.size.width, height: 40)
        }
                
        return .setToAspectRatioOfProvidedSize(size: CGSize(width: animationSize.width, height: animationSize.height))
    }
}
