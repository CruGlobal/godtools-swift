//
//  MobileContentFlowView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentFlowView: MobileContentStackView {
    
    private let viewModel: MobileContentFlowViewModelType
    
    private var flowItemRows: [MobileContentFlowRow] = Array()
    private var flowItemViews: [MobileContentFlowItemView] = Array()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        relayoutFlowForBoundsChange()
    }
    
    override func renderChild(childView: MobileContentView) {
                
        if let flowItemView = childView as? MobileContentFlowItemView {
            renderFlowItemView(flowItemView: flowItemView)
        }
        else {
            super.renderChild(childView: childView)
        }
    }
    
    override func finishedRenderingChildren() {
        super.finishedRenderingChildren()
        
        for row in flowItemRows {
            row.finishedRenderingChildren()
        }
    }

    private func relayoutFlowForBoundsChange() {
        
        removeAllChildren()
        flowItemRows.removeAll()

        for flowItemView in flowItemViews {
            renderChild(childView: flowItemView)
        }
        
        finishedRenderingChildren()
    }
}

// MARK: - Rendering FlowItemViews

extension MobileContentFlowView {
    
    private func renderFlowItemView(flowItemView: MobileContentFlowItemView) {
        
        flowItemViews.append(flowItemView)
        
        let row: MobileContentFlowRow
        
        if let currentRow = flowItemRows.last, currentRow.renderFlowItem(flowItemView: flowItemView) {
            
            row = currentRow
        }
        else {
            
            row = MobileContentFlowRow(
                rowGravity: viewModel.rowGravity
            )
            
            flowItemRows.append(row)
            
            super.renderChild(childView: row)
            
            row.renderFlowItem(flowItemView: flowItemView)
        }
    }
}
