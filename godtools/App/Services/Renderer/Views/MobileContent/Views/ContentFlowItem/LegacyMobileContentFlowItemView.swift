//
//  LegacyMobileContentFlowItemView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

@MainActor
protocol LegacyMobileContentFlowItemViewDelegate: AnyObject {
    
    func flowItemViewDidChangeVisibilityState(flowItemView: LegacyMobileContentFlowItemView, previousVisibilityState: MobileContentViewVisibilityState, visibilityState: MobileContentViewVisibilityState)
}

class LegacyMobileContentFlowItemView: LegacyMobileContentStackView, MobileContentFlowRowItem {
    
    private let viewModel: LegacyMobileContentFlowItemViewModel
    
    private weak var delegate: LegacyMobileContentFlowItemViewDelegate?
    
    var itemWidth: MobileContentViewWidth {
        return viewModel.width
    }
    var widthConstraint: NSLayoutConstraint?
    
    init(viewModel: LegacyMobileContentFlowItemViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: nil, scrollIsEnabled: false)
        
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBinding() {
        
        viewModel.visibilityState.addObserver(self) { [weak self] (visibilityState: MobileContentViewVisibilityState) in            
            
            guard let weakSelf = self else {
                return
            }
            
            let previousVisibilityState: MobileContentViewVisibilityState = weakSelf.visibilityState
            
            weakSelf.setVisibilityState(visibilityState: visibilityState)
            
            weakSelf.delegate?.flowItemViewDidChangeVisibilityState(flowItemView: weakSelf, previousVisibilityState: previousVisibilityState, visibilityState: visibilityState)
        }
    }
    
    func setDelegate(delegate: LegacyMobileContentFlowItemViewDelegate?) {
        
        self.delegate = delegate
    }
}
