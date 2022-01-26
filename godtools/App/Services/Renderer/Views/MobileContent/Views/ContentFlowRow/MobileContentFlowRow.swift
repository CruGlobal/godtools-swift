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
    
    private var remainingSpaceInPercentage: CGFloat = 1
    private var didLayoutHorizontalConstraints: Bool = false
    
    private var childItems: [MobileContentFlowRowItem] = Array()
    
    required init(rowGravity: Gravity.Horizontal) {
        
        self.rowGravity = rowGravity
        
        super.init(frame: UIScreen.main.bounds)
        
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
        
        for childView in childItems {
            childView.finishedRenderingChildren()
        }
        
        layoutFlowItemsHorizontalConstraints()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    private var containerWidth: CGFloat {
        return frame.size.width
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
        
        guard childItems.isEmpty || widthPercentage <= remainingSpaceInPercentage else {
            return false
        }
                
        super.renderChild(childView: flowItem)
        
        childItems.append(flowItem)
        
        addSubview(flowItem)
        
        remainingSpaceInPercentage -= widthPercentage
        
        flowItem.translatesAutoresizingMaskIntoConstraints = false
        
        flowItem.constrainTopToView(view: self)
        flowItem.constrainBottomToView(view: self)
        flowItem.addWidthConstraint(constant: widthPercentage * containerWidth)
        
        return true
    }
    
    private func layoutFlowItemsHorizontalConstraints() {
                
        guard !didLayoutHorizontalConstraints else {
            return
        }
        
        didLayoutHorizontalConstraints = true
        
        let itemSpacing: CGFloat = 0
        
        switch rowGravity {
            
        case .start:
            break
            
        case.center:
            break
            
        case .end:
            break
            
        default:
            break
        }
        
        let nextItem: MobileContentFlowRowItem
        
        for index in 0 ..< childItems.count {
            
            let currentItem: MobileContentFlowRowItem = childItems[index]
            let nextIndex: Int = index + 1
            
            if nextIndex < childItems.count {
                
                let nextItem: MobileContentFlowRowItem = childItems[nextIndex]
                
                let leading: NSLayoutConstraint = NSLayoutConstraint(
                    item: nextItem,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: currentItem,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: itemSpacing
                )
                
                nextItem.addConstraint(leading)
            }
        }
        
        if let firstItem = childItems.first {
            
            //firstItem.constrainLeadingToView(view: self)
        }
    }
}
