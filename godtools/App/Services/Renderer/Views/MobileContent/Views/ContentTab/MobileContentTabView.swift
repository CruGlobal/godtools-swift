//
//  MobileContentTabView.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTabView: MobileContentStackView {
    
    let viewModel: MobileContentTabViewModel
    
    init(viewModel: MobileContentTabViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: .zero, itemSpacing: 10, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
}
