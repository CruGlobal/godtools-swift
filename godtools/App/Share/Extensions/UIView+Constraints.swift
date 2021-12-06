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
            assertionFailure("Failed to constrain view edges to superview because a superview does not exist.  Is view added to a view hierarchy?")
            return
        }
        
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
    
    func centerHorizontallyToSuperview() {
        
        guard let superview = superview else {
            assertionFailure("Failed to center view horizontally because a superview does not exist.  Is view added to a view hierarchy?")
            return
        }
        
        let centerHorizontally: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: superview,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        
        addConstraint(centerHorizontally)
    }
    
    func centerVerticallyToSuperview() {
        
        guard let superview = superview else {
            assertionFailure("Failed to center view vertically because a superview does not exist.  Is view added to a view hierarchy?")
            return
        }
        
        let centerVertically: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: superview,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        
        superview.addConstraint(centerVertically)
    }
    
    func addWidthConstraint(constant: CGFloat, priority: CGFloat = 1000) {
        
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
    }
    
    func addHeightConstraint(constant: CGFloat, priority: CGFloat = 1000) {
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        heightConstraint.priority = UILayoutPriority(Float(priority))
        addConstraint(heightConstraint)
    }
}
