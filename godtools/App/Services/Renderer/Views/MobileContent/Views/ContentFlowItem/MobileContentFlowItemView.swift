//
//  MobileContentFlowItemView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

protocol MobileContentFlowItemViewDelegate: AnyObject {
    
    func flowItemViewDidChangeVisibilityState(flowItemView: MobileContentFlowItemView, previousVisibilityState: MobileContentViewVisibilityState, visibilityState: MobileContentViewVisibilityState)
}

class MobileContentFlowItemView: MobileContentStackView, MobileContentFlowRowItem {
    
    private let viewModel: MobileContentFlowItemViewModel
    
    private weak var delegate: MobileContentFlowItemViewDelegate?
    
    var itemWidth: MobileContentViewWidth {
        return viewModel.width
    }
    var widthConstraint: NSLayoutConstraint?
    
    init(viewModel: MobileContentFlowItemViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: .zero, itemSpacing: 0, scrollIsEnabled: false)
        
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
    
    func setDelegate(delegate: MobileContentFlowItemViewDelegate?) {
        
        self.delegate = delegate
    }
}
