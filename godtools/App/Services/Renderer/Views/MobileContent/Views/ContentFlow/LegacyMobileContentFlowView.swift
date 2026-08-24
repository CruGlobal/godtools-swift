//
//  LegacyMobileContentFlowView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class LegacyMobileContentFlowView: LegacyMobileContentStackView {
    
    private let viewModel: MobileContentFlowViewModel
    
    private var flowItemRows: [MobileContentFlowRow] = Array()
    private var flowItemViews: [LegacyMobileContentFlowItemView] = Array()
    
    init(viewModel: MobileContentFlowViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: nil, scrollIsEnabled: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        relayoutFlowForBoundsChange()
    }
    
    override func renderChild(childView: LegacyMobileContentView) {
                
        if let flowItemView = childView as? LegacyMobileContentFlowItemView {
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
        
        for flowItem in flowItemViews {
            flowItem.setDelegate(delegate: self)
        }
    }

    private func relayoutFlowForBoundsChange() {
                     
        let currentFlowItemsViews: [LegacyMobileContentFlowItemView] = flowItemViews
        
        removeAllChildren()
        flowItemRows.removeAll()
        flowItemViews.removeAll()
                
        for flowItemView in currentFlowItemsViews {
            renderChild(childView: flowItemView)
        }
        
        finishedRenderingChildren()
    }
}

// MARK: - Rendering FlowItemViews

extension LegacyMobileContentFlowView {
    
    private func renderFlowItemView(flowItemView: LegacyMobileContentFlowItemView) {
        
        flowItemViews.append(flowItemView)
        
        guard flowItemView.visibilityState != .gone else {
            return
        }
        
        let row: MobileContentFlowRow
        
        if let currentRow = flowItemRows.last, currentRow.renderFlowItem(flowItemView: flowItemView) {
            
            row = currentRow
        }
        else {
            
            row = MobileContentFlowRow(
                frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 100),
                rowGravity: viewModel.rowGravity,
                layoutDirection: viewModel.layoutDirection.semanticContentAttribute
            )
                        
            flowItemRows.append(row)
            
            super.renderChild(childView: row)
            
            _ = row.renderFlowItem(flowItemView: flowItemView)
        }
    }
}

// MARK: - LegacyMobileContentFlowItemViewDelegate

extension LegacyMobileContentFlowView: LegacyMobileContentFlowItemViewDelegate {
    
    func flowItemViewDidChangeVisibilityState(flowItemView: LegacyMobileContentFlowItemView, previousVisibilityState: MobileContentViewVisibilityState, visibilityState: MobileContentViewVisibilityState) {
        
        guard previousVisibilityState != visibilityState else {
            return
        }
        
        if previousVisibilityState == .gone || visibilityState == .gone {
            relayoutFlowForBoundsChange()
        }
                
        flowItemView.isHidden = visibilityState != .visible
    }
}
