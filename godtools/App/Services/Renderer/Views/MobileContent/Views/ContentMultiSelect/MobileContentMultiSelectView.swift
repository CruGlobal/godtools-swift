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
    
    private var optionViews: [MobileContentMultiSelectOptionView] = Array()
    private var optionViewsColumns: [[MobileContentMultiSelectOptionView]] = Array()
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
            addOptionViewToArray(optionView: optionView)
        }
        else {
            super.renderChild(childView: childView)
        }
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
        
        addOptionViews(optionViewsColumns: optionViewsColumns)
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}

extension MobileContentMultiSelectView {
    
    private func addOptionViewToArray(optionView: MobileContentMultiSelectOptionView) {
        
        optionViews.append(optionView)
        
        var numberOfColumns: Int = viewModel.numberOfColumnsForOptions
        if numberOfColumns <= 0 {
            numberOfColumns = 1
        }
        
        let optionViewIndex: Int = optionViews.count - 1
        let columnIndex: Int = optionViewIndex / numberOfColumns
        
        if columnIndex >= 0 && columnIndex < optionViewsColumns.count {
            
            optionViewsColumns[columnIndex].append(optionView)
        }
        else {
            
            var optionViewsColumn: [MobileContentMultiSelectOptionView] = Array()
            optionViewsColumn.append(optionView)
            optionViewsColumns.append(optionViewsColumn)
        }
    }
    
    private func addOptionViews(optionViewsColumns: [[MobileContentMultiSelectOptionView]]) {
        
        guard !optionViewsAdded else {
            return
        }
        optionViewsAdded = true
        
        for optionViewsColumn in optionViewsColumns {
            
            let contentRow: MobileContentRowView = MobileContentRowView(
                contentInsets: .zero,
                itemSpacing: MobileContentMultiSelectView.itemSpacing,
                numberOfColumns: viewModel.numberOfColumnsForOptions
            )
            
            super.renderChild(childView: contentRow)
            
            for optionView in optionViewsColumn {
                
                contentRow.renderChild(childView: optionView)
            }
            
            contentRow.finishedRenderingChildren()
        }
    }
}
