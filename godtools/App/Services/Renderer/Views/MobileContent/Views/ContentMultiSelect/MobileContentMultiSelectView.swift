//
//  MobileContentMultiSelectView.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentMultiSelectView: MobileContentView {
    
    private let viewModel: MobileContentMultiSelectViewModelType
    
    private var optionViews: [MobileContentMultiSelectOptionView] = Array()
    private var spacingBetweenOptionViews: CGFloat = 15
    private var optionViewsAdded: Bool = false
            
    required init(viewModel: MobileContentMultiSelectViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let optionView = childView as? MobileContentMultiSelectOptionView {
            optionViews.append(optionView)
        }
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
        
        addOptionViews(views: optionViews, spacingBetweenViews: spacingBetweenOptionViews)
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}

extension MobileContentMultiSelectView {
    
    private func addOptionViews(views: [MobileContentView], spacingBetweenViews: CGFloat) {
        
        guard !optionViewsAdded else {
            return
        }
        optionViewsAdded = true
        
        let parentView: UIView = self
        let numberOfViews: Int = optionViews.count
        let lastViewIndex: Int = numberOfViews - 1
        
        var previousChildView: MobileContentView?
        
        for index in stride(from: lastViewIndex, through: 0, by: -1) {
            
            let childView: MobileContentView = views[index]
            
            childView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(childView)
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 10
            )
            
            heightConstraint.priority = UILayoutPriority(500)
            
            childView.addConstraint(heightConstraint)
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            )
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
            
            let bottom: NSLayoutConstraint
            
            if index == lastViewIndex {
                
                bottom = NSLayoutConstraint(
                    item: childView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: parentView,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 0
                )
            }
            else if let previousChildView = previousChildView {
                
                bottom = NSLayoutConstraint(
                    item: childView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: previousChildView,
                    attribute: .top,
                    multiplier: 1,
                    constant: spacingBetweenViews * -1
                )
            }
            else {
                
                bottom = NSLayoutConstraint(
                    item: childView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: parentView,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 0
                )
            }
            
            parentView.addConstraint(leading)
            parentView.addConstraint(trailing)
            parentView.addConstraint(bottom)
            
            if index == 0 {
                
                let top: NSLayoutConstraint = NSLayoutConstraint(
                    item: childView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: parentView,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0
                )
                
                parentView.addConstraint(top)
            }
            
            previousChildView = childView
        }
    }
}
