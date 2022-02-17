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
        
        for childView in childItems {
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
        flowItem.setWidthConstraint(constant: widthPercentage * containerWidth)
        
        return true
    }
    
    private func layoutFlowItemsHorizontalConstraints() {
                
        guard !didLayoutHorizontalConstraints else {
            return
        }
        
        didLayoutHorizontalConstraints = true
        
        let itemSpacing: CGFloat
        
        switch rowGravity {
            
        case .start:
            itemSpacing = 0
            
        case.center:
            // TODO: itemSpacing should be equally set depending on remaining space.
            itemSpacing = 0
            
        case .end:
            itemSpacing = 0
            
        default:
            itemSpacing = 0
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
                
                addConstraint(leading)
            }
        }
        
        switch rowGravity {
            
        case .start:
            if let firstItem = childItems.first {
                firstItem.constrainLeadingToView(view: self)
            }
            
        case.center:
            if let firstItem = childItems.first {
                firstItem.constrainLeadingToView(view: self)
            }
            
        case .end:
            if let lastItem = childItems.last {
                lastItem.constrainTrailingToView(view: self)
            }
            
        default:
            if let firstItem = childItems.first {
                firstItem.constrainLeadingToView(view: self)
            }
        }
    }
}
