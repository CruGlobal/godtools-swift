//
//  MobileContentAnimationView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentAnimationView: MobileContentView {
    
    private let viewModel: MobileContentAnimationViewModelType
    private let animatedView: AnimatedView = AnimatedView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    required init(viewModel: MobileContentAnimationViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addSubview(animatedView)
        animatedView.constrainEdgesToSuperview()
    }
    
    private func setupBinding() {
        
        animatedView.configure(viewModel: viewModel.animatedViewModel)
    }
}
