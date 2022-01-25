//
//  MobileContentFlowView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentFlowView: MobileContentStackView {
    
    private let viewModel: MobileContentFlowViewModelType
    
    private var flowItemRows: [MobileContentRowView] = Array()
    
    required init(viewModel: MobileContentFlowViewModelType, itemSpacing: CGFloat) {
        
        self.viewModel = viewModel
        
        super.init(contentInsets: .zero, itemSpacing: itemSpacing, scrollIsEnabled: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    override func renderChild(childView: MobileContentView) {
                
        if let flowItemView = childView as? MobileContentFlowItemView {
            renderFlowItemView(flowItemView: flowItemView)
        }
        else {
            super.renderChild(childView: childView)
        }
    }
}

// MARK: - Rendering FlowItemViews

extension MobileContentFlowView {
    
    private func renderFlowItemView(flowItemView: MobileContentFlowItemView) {
        
        let flowItemRow: MobileContentRowView
        
        if let currentRow = flowItemRows.last, currentRow.canRenderChildView {
            
            flowItemRow = currentRow
        }
        else {
            
            flowItemRow = MobileContentRowView(
                contentInsets: .zero,
                itemSpacing: 0,
                numberOfColumns: 2
            )
            
            flowItemRows.append(flowItemRow)
            
            super.renderChild(childView: flowItemRow)
        }
        
        flowItemRow.renderChild(childView: flowItemView)
    }
}
