//
//  LegacyMobileContentMultiSelectView.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LegacyMobileContentMultiSelectView: LegacyMobileContentStackView {
        
    private static let multiSelectOptionSpacing: CGFloat = 15
    
    private let viewModel: MobileContentMultiSelectViewModel
    private let itemSpacing: CGFloat
    private let isSingleColumn: Bool
    
    private var multiSelectOptionRows: [LegacyMobileContentRowView] = Array()
    private var optionViewsAdded: Bool = false
            
    init(viewModel: MobileContentMultiSelectViewModel) {
        
        let isSingleColumn: Bool = viewModel.numberOfColumnsForOptions == 1
        let itemSpacing: CGFloat = 15
        
        self.viewModel = viewModel
        self.itemSpacing = itemSpacing
        self.isSingleColumn = isSingleColumn
        
        super.init(viewModel: viewModel, contentInsets: nil, scrollIsEnabled: false, itemSpacing: Self.multiSelectOptionSpacing)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    override func renderChild(childView: LegacyMobileContentView) {
                
        if let optionView = childView as? LegacyMobileContentMultiSelectOptionView {
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

extension LegacyMobileContentMultiSelectView {
    
    private func renderOptionView(optionView: LegacyMobileContentMultiSelectOptionView) {
        
        let multiSelectOptionRow: LegacyMobileContentRowView
        
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
    
    private func getNewMultiSelectOptionRow() -> LegacyMobileContentRowView {
        
        return LegacyMobileContentRowView(
            contentInsets: .zero,
            itemSpacing: itemSpacing,
            numberOfColumns: viewModel.numberOfColumnsForOptions
        )
    }
}
