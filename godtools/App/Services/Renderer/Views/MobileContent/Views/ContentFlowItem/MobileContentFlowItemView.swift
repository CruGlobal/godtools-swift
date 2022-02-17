//
//  MobileContentFlowItemView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentFlowItemView: MobileContentStackView, MobileContentFlowRowItem {
    
    private let viewModel: MobileContentFlowItemViewModelType
    
    var itemWidth: MobileContentViewWidth {
        return viewModel.width
    }
    var widthConstraint: NSLayoutConstraint?
    
    required init(viewModel: MobileContentFlowItemViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(contentInsets: .zero, itemSpacing: 0, scrollIsEnabled: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
}
