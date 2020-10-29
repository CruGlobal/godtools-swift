//
//  UIView+Containment.swift
//  godtools
//
//  Created by Levi Eggert on 10/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIView {
    
    func constrainEdgesToSuperview() {
        
        if let superview = superview {
            
            translatesAutoresizingMaskIntoConstraints = false
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .leading,
                relatedBy: .equal,
                toItem: superview,
                attribute: .leading,
                multiplier: 1,
                constant: 0)
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: superview,
                attribute: .trailing,
                multiplier: 1,
                constant: 0)
            
            let top: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .top,
                relatedBy: .equal,
                toItem: superview,
                attribute: .top,
                multiplier: 1,
                constant: 0)
            
            let bottom: NSLayoutConstraint = NSLayoutConstraint(
                item: self,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: superview,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
            
            superview.addConstraint(leading)
            superview.addConstraint(trailing)
            superview.addConstraint(top)
            superview.addConstraint(bottom)
        }
    }
}
