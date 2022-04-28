//
//  MobileContentFlowRow.swift
//  godtools
//
//  Created by Levi Eggert on 1/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentFlowRow: MobileContentView {
    
    private let rowGravity: Gravity.Horizontal
    
    private var didLayoutHorizontalConstraints: Bool = false
    
    private var flowItems: [MobileContentFlowRowItem] = Array()
    
    required init(frame: CGRect, rowGravity: Gravity.Horizontal) {
        
        self.rowGravity = rowGravity
        
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        backgroundColor = .clear
    }
    
    func renderFlowItem(flowItemView: MobileContentFlowRowItem) -> Bool {
        
        if !flowItemView.heightConstraintType.isConstrainedByChildren {
            assertionFailure("Only heightConstraintType with value .constrainedToChildren is supported on child views.")
            return false
        }
                
        return addFlowItemView(flowItem: flowItemView)
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
        
        for childView in flowItems {
            childView.finishedRenderingChildren()
        }
        
        layoutFlowItemsHorizontalConstraints()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    private var containerWidth: CGFloat {
        let containerWidth: CGFloat = frame.size.width
        return containerWidth
    }
    
    private func getRemainingSpaceInRowMinusFlowItems() -> CGFloat {
        
        let combinedAddedFlowItemsWidth: CGFloat = flowItems.reduce(0) { $0 + $1.widthConstraintConstant }
        let remainingSpaceInRowMinusFlowItems: CGFloat = containerWidth - combinedAddedFlowItemsWidth
        
        return remainingSpaceInRowMinusFlowItems
    }
    
    private func getFlowItemWidthPercentageOfContainer(flowItem: MobileContentFlowRowItem) -> CGFloat {
                        
        let viewWidthPercentageOfContainer: CGFloat
        
        switch flowItem.itemWidth {
        
        case .percentageOfContainer(let value):
            viewWidthPercentageOfContainer = value
        
        case .points(let value):
            viewWidthPercentageOfContainer = value / containerWidth
        }
        
        let flooredViewWidthPercentageOfContainer: CGFloat = floor(viewWidthPercentageOfContainer * 100) / 100

        return flooredViewWidthPercentageOfContainer
    }
    
    private func addFlowItemView(flowItem: MobileContentFlowRowItem) -> Bool {
        
        let widthPercentage: CGFloat = getFlowItemWidthPercentageOfContainer(flowItem: flowItem)
        let flowItemWidth: CGFloat = floor(widthPercentage * containerWidth)
        
        let remainingSpaceInRowMinusFlowItems: CGFloat = getRemainingSpaceInRowMinusFlowItems()
        
        guard flowItems.isEmpty || flowItemWidth <= remainingSpaceInRowMinusFlowItems else {
            return false
        }
                
        super.renderChild(childView: flowItem)
        
        flowItems.append(flowItem)
        
        addSubview(flowItem)
                
        flowItem.translatesAutoresizingMaskIntoConstraints = false
        
        flowItem.constrainTopToView(view: self)
        flowItem.constrainBottomToView(view: self)
        flowItem.setWidthConstraint(constant: flowItemWidth)
                        
        return true
    }
    
    private func layoutFlowItemsHorizontalConstraints() {
                
        guard !didLayoutHorizontalConstraints else {
            return
        }
                
        didLayoutHorizontalConstraints = true
        
        let remainingSpaceInRowMinusFlowItems: CGFloat = getRemainingSpaceInRowMinusFlowItems()
        
        let itemsLeadingToRow: CGFloat
        let itemsTrailingToRow: CGFloat
        let spacingBetweenItems: CGFloat
        
        switch rowGravity {
            
        case .start:
            itemsLeadingToRow = 0
            itemsTrailingToRow = remainingSpaceInRowMinusFlowItems
            spacingBetweenItems = 0
            
        case.center:
                    
            let spacesNeededForLeading: CGFloat = 1
            let spacesNeededForTrailing: CGFloat = 1
            let spacesNeededForItems: CGFloat = CGFloat(flowItems.count) - 1
            let numberOfSpacesNeeded: CGFloat = spacesNeededForLeading + spacesNeededForTrailing + spacesNeededForItems
            let equalSpacing: CGFloat = remainingSpaceInRowMinusFlowItems / numberOfSpacesNeeded
            
            spacingBetweenItems = equalSpacing
            itemsLeadingToRow = equalSpacing
            itemsTrailingToRow = equalSpacing
            
        case .end:
            itemsLeadingToRow = remainingSpaceInRowMinusFlowItems
            itemsTrailingToRow = 0
            spacingBetweenItems = 0
            
        default:
            itemsLeadingToRow = 0
            itemsTrailingToRow = remainingSpaceInRowMinusFlowItems
            spacingBetweenItems = 0
        }
                
        for index in 0 ..< flowItems.count {
            
            let currentItem: MobileContentFlowRowItem = flowItems[index]
            let nextIndex: Int = index + 1
            
            if nextIndex < flowItems.count {
                
                let nextItem: MobileContentFlowRowItem = flowItems[nextIndex]
                
                let leading: NSLayoutConstraint = NSLayoutConstraint(
                    item: nextItem,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: currentItem,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: spacingBetweenItems
                )
                
                addConstraint(leading)
            }
        }
        
        if let firstItem = flowItems.first {
            firstItem.constrainLeadingToView(view: self, constant: itemsLeadingToRow)
        }
        if let lastItem = flowItems.last {
            lastItem.constrainTrailingToView(view: self, constant: itemsTrailingToRow)
        }
    }
}
