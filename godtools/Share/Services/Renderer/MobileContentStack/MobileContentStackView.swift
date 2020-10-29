//
//  MobileContentStackView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentStackView: UIView {
    
    private let node: MobileContentXmlNode
    private let stackView: UIStackView = UIStackView()
    
    private(set) var scrollView: UIScrollView?
        
    required init(node: MobileContentXmlNode, viewSpacing: CGFloat, scrollIsEnabled: Bool) {
                     
        self.node = node
        
        super.init(frame: .zero)
        
        setupConstraints(
            parentView: self,
            scrollIsEnabled: scrollIsEnabled
        )
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = viewSpacing
        
        scrollView?.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addContentView(view: UIView) {
               
        if let verticalStack = view as? MobileContentStackView {
            stackView.addArrangedSubview(verticalStack.stackView)
            return
        }
        
        let viewUsesIntrinsicContentSize: Bool = view is UILabel
        
        if !viewUsesIntrinsicContentSize {
            view.heightAnchor.constraint(equalToConstant: view.bounds.size.height).isActive = true
        }
        
        stackView.addArrangedSubview(view)
    }
    
    private func setupConstraints(parentView: UIView, scrollIsEnabled: Bool) {
            
        translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        if scrollIsEnabled {
            
            let scrollView: UIScrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            parentView.addSubview(scrollView)
            scrollView.addSubview(stackView)
            
            constrainViewEdgesToSuperview(view: scrollView)
            constrainViewEdgesToSuperview(view: stackView)
                        
            let equalWidths: NSLayoutConstraint = NSLayoutConstraint(
                item: scrollView,
                attribute: .width,
                relatedBy: .equal,
                toItem: stackView,
                attribute: .width,
                multiplier: 1,
                constant: 0
            )
            
            scrollView.addConstraint(equalWidths)
            
            self.scrollView = scrollView
        }
        else {
            
            parentView.addSubview(stackView)
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: stackView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0)
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: stackView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0)
            
            let top: NSLayoutConstraint = NSLayoutConstraint(
                item: stackView,
                attribute: .top,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .top,
                multiplier: 1,
                constant: 0)
            
            parentView.addConstraint(leading)
            parentView.addConstraint(trailing)
            parentView.addConstraint(top)
        }
        
        addHeightConstraintToView(view: stackView, height: 10, priority: 500)
    }
}

// MARK: - Constraints

extension MobileContentStackView {
    
    private func addHeightConstraintToView(view: UIView, height: CGFloat, priority: Float) {
    
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: height
        )
        
        heightConstraint.priority = UILayoutPriority(priority)
        
        view.addConstraint(heightConstraint)
    }
    
    private func constrainViewEdgesToSuperview(view: UIView) {
        
        guard let superview = view.superview else {
            return
        }
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: superview,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: superview,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .top,
            relatedBy: .equal,
            toItem: superview,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: superview,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        superview.addConstraint(leading)
        superview.addConstraint(trailing)
        superview.addConstraint(top)
        superview.addConstraint(bottom)
    }
}
