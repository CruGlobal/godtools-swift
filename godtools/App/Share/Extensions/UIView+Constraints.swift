//
//  UIView+Constraints.swift
//  godtools
//
//  Created by Levi Eggert on 10/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIView {
    
    func constrainEdgesToSuperview(edgeInsets: UIEdgeInsets = .zero) {
        
        guard let superview = self.superview else {
            // TODO: Instead of checking for superview, force view as argument. ~Levi
            //assertionFailure("Failed to constrain view edges to superview because a superview does not exist.  Is view added to a view hierarchy?")
            print("\n WARNING: Failed to constrain edges to superview because superview is null.")
            return
        }
        
        // TODO: Don't set this here, require caller to make this. ~Levi
        translatesAutoresizingMaskIntoConstraints = false
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .leading,
            relatedBy: .equal,
            toItem: superview,
            attribute: .leading,
            multiplier: 1,
            constant: edgeInsets.left
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: superview,
            attribute: .trailing,
            multiplier: 1,
            constant: edgeInsets.right * -1
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: superview,
            attribute: .top,
            multiplier: 1,
            constant: edgeInsets.top
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: superview,
            attribute: .bottom,
            multiplier: 1,
            constant: edgeInsets.bottom * -1
        )
        
        superview.addConstraint(leading)
        superview.addConstraint(trailing)
        superview.addConstraint(top)
        superview.addConstraint(bottom)
    }
    
    func constrainEdgesToView(view: UIView) {
        
        constrainTopToView(view: view)
        constrainBottomToView(view: view)
        constrainLeadingToView(view: view)
        constrainTrailingToView(view: view)
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
    
    func constrainBottomToView(view: UIView, constant: CGFloat = 0) {
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: constant
        )
        
        view.addConstraint(bottom)
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
            constant: constant
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
    
    func addWidthConstraint(constant: CGFloat, priority: CGFloat = 1000) -> NSLayoutConstraint {
        
        let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
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
