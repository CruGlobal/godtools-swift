//
//  LegacyMobileContentTabView.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LegacyMobileContentTabView: LegacyMobileContentStackView {
    
    let viewModel: LegacyMobileContentTabViewModel
    
    init(viewModel: LegacyMobileContentTabViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: nil, scrollIsEnabled: false)
        
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
