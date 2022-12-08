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
    private let touchAreaButton: UIButton = UIButton(type: .custom)
    
    init(viewModel: MobileContentAnimationViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        touchAreaButton.addTarget(self, action: #selector(touchAreaTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // animatedView
        addSubview(animatedView)
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        animatedView.constrainEdgesToView(view: self)
        
        // touchAreaButton
        addSubview(touchAreaButton)
        touchAreaButton.translatesAutoresizingMaskIntoConstraints = false
        touchAreaButton.constrainEdgesToView(view: self)
        touchAreaButton.backgroundColor = .clear
    }
    
    private func setupBinding() {
        
        if let animatedViewModel = viewModel.animatedViewModel {
            animatedView.configure(viewModel: animatedViewModel)
            animatedView.setAnimationContentMode(contentMode: .scaleAspectFill)
        }
    }
    
    @objc private func touchAreaTapped() {
        
        viewModel.animationTapped()
        
        super.sendEventsToAllViews(eventIds: viewModel.animationEvents, rendererState: viewModel.rendererState)
        
        if let clickableUrl = viewModel.getClickableUrl() {
            super.sendButtonWithUrlEventToRootView(url: clickableUrl)
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
