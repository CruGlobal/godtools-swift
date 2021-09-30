//
//  MobileContentMultiSelectView.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentMultiSelectView: MobileContentStackView {
        
    private let viewModel: MobileContentMultiSelectViewModelType
    private let itemSpacing: CGFloat
    private let shadowEdgeInsets: UIEdgeInsets
    private let isSingleColumn: Bool
    private let supportsShadowsOnOptionsViews: Bool
    
    private var multiSelectOptionRows: [MobileContentRowView] = Array()
    private var optionViewsAdded: Bool = false
            
    required init(viewModel: MobileContentMultiSelectViewModelType) {
        
        let itemSpacing: CGFloat
        let shadowEdgeInsets: UIEdgeInsets
        let isSingleColumn: Bool = viewModel.numberOfColumnsForOptions == 1
        let supportsShadowsOnOptionsViews: Bool = true
        
        if isSingleColumn && supportsShadowsOnOptionsViews {
            
            itemSpacing = 35
            shadowEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        }
        else {
            
            itemSpacing = 15
            shadowEdgeInsets = .zero
        }
        
        self.viewModel = viewModel
        self.itemSpacing = itemSpacing
        self.shadowEdgeInsets = shadowEdgeInsets
        self.isSingleColumn = isSingleColumn
        self.supportsShadowsOnOptionsViews = supportsShadowsOnOptionsViews
        
        super.init(contentInsets: .zero, itemSpacing: itemSpacing, scrollIsEnabled: false)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    override func renderChild(childView: MobileContentView) {
                
        if let optionView = childView as? MobileContentMultiSelectOptionView {
            renderOptionView(optionView: optionView)
        }
        else {
            super.renderChild(childView: childView)
        }
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
                
        for multiSelectOptionRow in multiSelectOptionRows {
            multiSelectOptionRow.finishedRenderingChildren()
        }
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Rendering MultiSelectOptionViews

extension MobileContentMultiSelectView {
    
    private func renderOptionView(optionView: MobileContentMultiSelectOptionView) {
        
        let multiSelectOptionRow: MobileContentRowView
        
        if let currentRow = multiSelectOptionRows.last, currentRow.canRenderChildView {
            
            multiSelectOptionRow = currentRow
        }
        else {
            
            multiSelectOptionRow = getNewMultiSelectOptionRow()
            
            multiSelectOptionRows.append(multiSelectOptionRow)
            
            super.renderChild(childView: multiSelectOptionRow)
        }
        
        multiSelectOptionRow.renderChild(childView: optionView)
        
        if supportsShadowsOnOptionsViews {
            optionView.drawShadow(shadowEdgeInsetsToSuperView: shadowEdgeInsets, cornerRadius: 10)
        }
    }
    
    private func getNewMultiSelectOptionRow() -> MobileContentRowView {
        
        return MobileContentRowView(
            contentInsets: .zero,
            itemSpacing: itemSpacing,
            numberOfColumns: viewModel.numberOfColumnsForOptions
        )
    }
}
