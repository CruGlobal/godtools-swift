//
//  MobileContentAnimationView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentAnimationView: MobileContentView {
    
    private let viewModel: MobileContentAnimationViewModelType
    private let animatedView: AnimatedView = AnimatedView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    private let touchAreaButton: UIButton = UIButton(type: .custom)
    
    required init(viewModel: MobileContentAnimationViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
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
        s
        // touchAreaButton
        addSubview(touchAreaButton)
        touchAreaButton.translatesAutoresizingMaskIntoConstraints = false
        touchAreaButton.constrainEdgesToView(view: self)
        touchAreaButton.backgroundColor = .clear
    }
    
    private func setupBinding() {
        
        animatedView.configure(viewModel: viewModel.animatedViewModel)
        animatedView.setAnimationContentMode(contentMode: .scaleAspectFill)
    }
    
    @objc private func touchAreaTapped() {
        
        viewModel.animationTapped()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        
        let animationAssetSize: CGSize = viewModel.animatedViewModel.getAssetSize()
        
        return .setToAspectRatioOfProvidedSize(size: CGSize(width: animationAssetSize.width, height: animationAssetSize.height))
    }
}
