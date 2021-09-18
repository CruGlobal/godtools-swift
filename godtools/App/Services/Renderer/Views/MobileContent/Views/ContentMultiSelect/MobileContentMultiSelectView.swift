//
//  MobileContentMultiSelectView.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentMultiSelectView: MobileContentStackView {
    
    private static let itemSpacing: CGFloat = 15
    
    private let viewModel: MobileContentMultiSelectViewModelType
    
    private var multiSelectOptionRows: [MobileContentRowView] = Array()
    private var spacingBetweenOptionViews: CGFloat = 15
    private var optionViewsAdded: Bool = false
            
    required init(viewModel: MobileContentMultiSelectViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(itemHorizontalInsets: 0, itemSpacing: MobileContentMultiSelectView.itemSpacing, scrollIsEnabled: false)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemHorizontalInsets: CGFloat, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemHorizontalInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
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
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
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
            itemSpacing: MobileContentMultiSelectView.itemSpacing,
            numberOfColumns: viewModel.numberOfColumnsForOptions
        )
    }
}
