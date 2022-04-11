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
    private let isSingleColumn: Bool
    
    private var multiSelectOptionRows: [MobileContentRowView] = Array()
    private var optionViewsAdded: Bool = false
            
    required init(viewModel: MobileContentMultiSelectViewModelType) {
        
        let isSingleColumn: Bool = viewModel.numberOfColumnsForOptions == 1
        let itemSpacing: CGFloat = isSingleColumn ? 35 : 15
        
        self.viewModel = viewModel
        self.itemSpacing = itemSpacing
        self.isSingleColumn = isSingleColumn
        
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
    }
    
    private func getNewMultiSelectOptionRow() -> MobileContentRowView {
        
        return MobileContentRowView(
            contentInsets: .zero,
            itemSpacing: itemSpacing,
            numberOfColumns: viewModel.numberOfColumnsForOptions
        )
    }
}
