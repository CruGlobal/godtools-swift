//
//  MobileContentTabView.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTabView: MobileContentStackView {
    
    let viewModel: MobileContentTabViewModelType
    
    required init(viewModel: MobileContentTabViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(itemHorizontalInsets: 0, itemSpacing: 10, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemHorizontalInsets: CGFloat, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemHorizontalInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
}
