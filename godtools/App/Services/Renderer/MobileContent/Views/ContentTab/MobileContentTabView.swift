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
        
        super.init(itemSpacing: 10, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
    }
    
    required init(itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
}
