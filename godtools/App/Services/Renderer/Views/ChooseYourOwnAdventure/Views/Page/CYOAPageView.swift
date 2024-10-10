//
//  CYOAPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit

class CYOAPageView: MobileContentContentPageView {
    
    private let viewModel: CYOAPageViewModel
    
    init(viewModel: CYOAPageViewModel, contentInsets: UIEdgeInsets, itemSpacing: CGFloat) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: contentInsets, itemSpacing: itemSpacing)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
