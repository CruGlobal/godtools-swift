//
//  UIKit+Extensions.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UILabel {
    
    func getAttributedString() -> NSMutableAttributedString {
        return attributedText?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
    }
    
    func getRangeOfString(string: String) -> NSRange {
        if let text = text {
            return (text as NSString).range(of: string)
        }
        return NSMakeRange(0, 0)
    }
    
    func setLineSpacing(lineSpacing: CGFloat) {
        if let text = text {
            if !text.isEmpty {
                let currTextAlignment: NSTextAlignment = textAlignment
                let attributedString: NSMutableAttributedString = getAttributedString()
                let range: NSRange = getRangeOfString(string: text)
                let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = lineSpacing
                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
                attributedText = attributedString
                textAlignment = currTextAlignment
            }
        }
    }
}

extension UIView {
    
    func drawBorder(color: UIColor = UIColor.red) {
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
    }
    
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
