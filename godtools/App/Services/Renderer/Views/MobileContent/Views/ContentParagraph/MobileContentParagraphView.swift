//
//  MobileContentParagraphView.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentParagraphView: MobileContentStackView {
    
    private let viewModel: MobileContentParagraphViewModelType
    
    required init(viewModel: MobileContentParagraphViewModelType, contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        
        self.viewModel = viewModel
        
        super.init(contentInsets: contentInsets, itemSpacing: itemSpacing, scrollIsEnabled: scrollIsEnabled)
        
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func setupBinding() {
        
        viewModel.visibilityState.addObserver(self) { [weak self] (visibilityState: MobileContentViewVisibilityState) in
            self?.setVisibilityState(visibilityState: visibilityState)
        }
    }
}
