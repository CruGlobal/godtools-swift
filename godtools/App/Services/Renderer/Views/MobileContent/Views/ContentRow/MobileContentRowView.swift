//
//  MobileContentRowView.swift
//  godtools
//
//  Created by Levi Eggert on 9/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentRowView: MobileContentView {
        
    private let contentInsets: UIEdgeInsets
    private let itemSpacing: CGFloat
    private let numberOfColumns: Int
    
    private var childViews: [MobileContentView] = Array()
    private var childViewsWidthConstraints: [NSLayoutConstraint] = Array()
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, numberOfColumns: Int) {
        
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        self.numberOfColumns = numberOfColumns
        
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .clear
        
        updateChildWidthForBoundsChange()
    }
    
    override func renderChild(childView: MobileContentView) {
        
        if !childView.contentStackHeightConstraintType.isConstrainedByChildren {
            assertionFailure("Only contentStackHeightConstraintType with value .constrainedToChildren is supported on child views.")
        }
        
        guard childViews.count < numberOfColumns else {
            assertionFailure("Failed to add childView.  Number of added childViews already equals numberOfColumns for this view.")
            return
        }
        
        super.renderChild(childView: childView)
        
        childViews.append(childView)
        
        let childIndex: Int = childViews.count - 1
        let isLastChildView: Bool = childViews.count == numberOfColumns
        let childWidth: CGFloat = calculateChildWidth()
        
        addChildViewToParent(childView: childView)
        addChildViewWidthConstraint(childView: childView, childWidth: childWidth)
        addTopAndBottomConstraints(childView: childView, contentInsets: contentInsets)
        
        let previousChildIndex: Int = childIndex - 1
        let previousChildView: MobileContentView?
        
        if previousChildIndex >= 0 {
            previousChildView = childViews[previousChildIndex]
        }
        else {
            previousChildView = nil
        }
                
        addChildViewLeadingAndTrailingConstraints(
            childView: childView,
            previousChildView: previousChildView,
            isLastChildView: isLastChildView,
            contentInsets: contentInsets,
            itemSpacing: itemSpacing
        )
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
        
        updateChildWidthForBoundsChange()
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    private func calculateChildWidth() -> CGFloat {
        
        let numberOfColumnsFloat: CGFloat = CGFloat(numberOfColumns)
        let rowWidth: CGFloat = frame.size.width
        let combinedItemSpacing: CGFloat = itemSpacing * (numberOfColumnsFloat - 1)
        let childWidth: CGFloat = floor((rowWidth - contentInsets.left - contentInsets.right - combinedItemSpacing) / numberOfColumnsFloat)
        
        return childWidth
    }
    
    private func updateChildWidthForBoundsChange() {
        
        let childWidth: CGFloat = calculateChildWidth()
        
        for childWidthConstraint in childViewsWidthConstraints {
            
            childWidthConstraint.constant = childWidth
        }
        
        layoutIfNeeded()
    }
    
    private func addChildViewToParent(childView: MobileContentView) {
        
        guard !subviews.contains(childView) else {
            return
        }
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(childView)
    }
    
    private func addChildViewWidthConstraint(childView: MobileContentView, childWidth: CGFloat) {
        
        // width constraint
        let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: childView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: childWidth
        )
        
        widthConstraint.priority = UILayoutPriority(1000)
        
        childView.addConstraint(widthConstraint)
        
        childViewsWidthConstraints.append(widthConstraint)
    }
    
    private func addChildViewLeadingAndTrailingConstraints(childView: MobileContentView, previousChildView: MobileContentView?, isLastChildView: Bool, contentInsets: UIEdgeInsets, itemSpacing: CGFloat) {
        
        // leading
        let leadingToItem: UIView
        let leadingConstant: CGFloat
        let leadingToAttribute: NSLayoutConstraint.Attribute
        
        if let previousChildView = previousChildView {
            
            leadingToItem = previousChildView
            leadingConstant = itemSpacing
            leadingToAttribute = .trailing
        }
        else {
            
            leadingToItem = self
            leadingConstant = contentInsets.left
            leadingToAttribute = .leading
        }
                
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: childView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: leadingToItem,
            attribute: leadingToAttribute,
            multiplier: 1,
            constant: leadingConstant
        )
        
        addConstraint(leading)
        
        // trailing
        if isLastChildView {
            
            let trailingToItem: UIView = self
            let trailingConstant: CGFloat = contentInsets.right
            let trailingToAttribute: NSLayoutConstraint.Attribute = .trailing
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: trailingToItem,
                attribute: trailingToAttribute,
                multiplier: 1,
                constant: trailingConstant
            )
            
            addConstraint(trailing)
        }
    }
    
    private func addTopAndBottomConstraints(childView: MobileContentView, contentInsets: UIEdgeInsets) {
        
        // top
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: childView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: contentInsets.top
        )
        
        addConstraint(top)
        
        // bottom
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: childView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: contentInsets.bottom
        )
        
        addConstraint(bottom)
    }
}
