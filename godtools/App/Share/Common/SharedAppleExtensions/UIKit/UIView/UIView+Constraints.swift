//
//  UIView+Constraints.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 10/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

public extension UIView {
    
    func constrainEdgesToView(view: UIView, edgeInsets: UIEdgeInsets = .zero, horizontalConstraintType: UIViewHorizontalContraintType = .leadingAndTrailing) {
        
        constrainTopToView(view: view, constant: edgeInsets.top)
        _ = constrainBottomToView(view: view, constant: edgeInsets.bottom)
        
        switch horizontalConstraintType {
        case .leadingAndTrailing:
            constrainLeadingToView(view: view, constant: edgeInsets.left)
            constrainTrailingToView(view: view, constant: edgeInsets.right)
        case .leftAndRight:
            constrainLeftToView(view: view, constant: edgeInsets.left)
            constrainRightToView(view: view, constant: edgeInsets.right)
        }
    }
    
    func constrainTopToView(view: UIView, constant: CGFloat = 0) {
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .top,
            multiplier: 1,
            constant: constant
        )
        
        view.addConstraint(top)
    }
    
    func constrainBottomToView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: constant * -1
        )
        
        view.addConstraint(bottom)
        
        return bottom
    }
    
    func constrainLeftToView(view: UIView, constant: CGFloat = 0) {
        
        let left: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .left,
            relatedBy: .equal,
            toItem: view,
            attribute: .left,
            multiplier: 1,
            constant: constant
        )
        
        view.addConstraint(left)
    }
    
    func constrainRightToView(view: UIView, constant: CGFloat = 0) {
        
        let right: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .right,
            relatedBy: .equal,
            toItem: view,
            attribute: .right,
            multiplier: 1,
            constant: constant * -1
        )
        
        view.addConstraint(right)
    }
    
    func constrainLeadingToView(view: UIView, constant: CGFloat = 0) {
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1,
            constant: constant
        )
        
        view.addConstraint(leading)
    }
    
    func constrainTrailingToView(view: UIView, constant: CGFloat = 0) {
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1,
            constant: constant * -1
        )
        
        view.addConstraint(trailing)
    }
    
    func constrainCenterHorizontallyInView(view: UIView) {
        
        let centerHorizontally: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        
        view.addConstraint(centerHorizontally)
    }
    
    func constrainCenterVerticallyInView(view: UIView) {
        
        let centerVertically: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        
        view.addConstraint(centerVertically)
    }
    
    func addWidthConstraint(constant: CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, priority: CGFloat = 1000) -> NSLayoutConstraint {
        
        let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: relatedBy,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        widthConstraint.priority = UILayoutPriority(Float(priority))
        addConstraint(widthConstraint)
        
        return widthConstraint
    }
    
    func addHeightConstraint(constant: CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, priority: CGFloat = 1000) -> NSLayoutConstraint {
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: relatedBy,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        heightConstraint.priority = UILayoutPriority(Float(priority))
        addConstraint(heightConstraint)
        
        return heightConstraint
    }
}
