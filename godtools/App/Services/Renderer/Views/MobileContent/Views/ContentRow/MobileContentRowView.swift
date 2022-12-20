//
//  MobileContentRowView.swift
//  godtools
//
//  Created by Levi Eggert on 9/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentRowView: MobileContentView {
        
    private let horizontalStackView: UIStackView
    private let contentInsets: UIEdgeInsets
    private let itemSpacing: CGFloat
    private let numberOfColumns: Int
    
    private var childViews: [MobileContentView] = Array()
    private var horizontalStackViewTrailing: NSLayoutConstraint?
    
    init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, numberOfColumns: Int) {
        
        self.horizontalStackView = UIStackView(frame: UIScreen.main.bounds)
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        self.numberOfColumns = numberOfColumns
        
        super.init(viewModel: nil, frame: UIScreen.main.bounds)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        backgroundColor = .clear
        
        addHorizontalStackView()
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = itemSpacing
    }
    
    var canRenderChildView: Bool {
        return childViews.count < numberOfColumns
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateStackViewToFitNumberOfChildViewsIfNeeded()
    }
    
    override func renderChild(childView: MobileContentView) {
        
        if !childView.heightConstraintType.isConstrainedByChildren {
            assertionFailure("Only heightConstraintType with value .constrainedToChildren is supported on child views.")
        }
        
        guard canRenderChildView else {
            assertionFailure("Failed to add childView.  Number of added childViews already equals numberOfColumns for this view.")
            return
        }
        
        super.renderChild(childView: childView)
        
        childViews.append(childView)
        
        horizontalStackView.addArrangedSubview(childView)
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
        
        for childView in childViews {
            childView.finishedRenderingChildren()
        }
        
        updateStackViewToFitNumberOfChildViewsIfNeeded()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    private func updateStackViewToFitNumberOfChildViewsIfNeeded() {
        
        let remainingEmptyChildViewColumns: Int = numberOfColumns - childViews.count
        
        guard remainingEmptyChildViewColumns > 0 else {
            return
        }
        
        let parentBounds: CGRect = frame
        let numberOfColumnsFloat: CGFloat = CGFloat(numberOfColumns)
        let combinedItemSpacing: CGFloat = itemSpacing * (numberOfColumnsFloat - 1)
        let childWidth: CGFloat = (parentBounds.size.width - contentInsets.left - contentInsets.right - combinedItemSpacing) / numberOfColumnsFloat
        
        let remainingSpaceForEmptyChildViewColumns: CGFloat = CGFloat(remainingEmptyChildViewColumns) * (childWidth + itemSpacing)
        let baseHorizontalStackViewTrailing: CGFloat = contentInsets.right
        
        horizontalStackViewTrailing?.constant = (remainingSpaceForEmptyChildViewColumns + baseHorizontalStackViewTrailing) * -1
        
        layoutIfNeeded()
    }
}

// MARK: - Add Horizontal Stack View

extension MobileContentRowView {
    
    private func addHorizontalStackView() {
        
        addSubview(horizontalStackView)
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: horizontalStackView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: contentInsets.left
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: horizontalStackView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: contentInsets.right * -1
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: horizontalStackView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: contentInsets.top
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: horizontalStackView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: contentInsets.bottom * -1
        )
        
        horizontalStackViewTrailing = trailing
        
        addConstraint(leading)
        addConstraint(trailing)
        addConstraint(top)
        addConstraint(bottom)
    }
}
