//
//  UIKit+Extensions.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIButton {
    
    func centerTitleAndSetImageRightOfTitleWithSpacing(spacing: CGFloat) {
        
        if let titleLabel = titleLabel, let image = image(for: .normal) {
            
            let imageWidth: CGFloat = image.size.width
            
            titleLabel.sizeToFit()
            
            contentHorizontalAlignment = .left
            
            let buttonWidth: CGFloat = frame.size.width
            let titleWidth: CGFloat = titleLabel.frame.size.width
            let titleLeft: CGFloat = (buttonWidth / 2 - titleWidth / 2) - imageWidth
            
            titleEdgeInsets = UIEdgeInsets(top: 0, left: titleLeft, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLeft + titleWidth + spacing, bottom: 0, right: 0)
        }
    }
    
    func setImageColor(color: UIColor) {
        if let image = image(for: .normal) {
            let newImage: UIImage = image.withRenderingMode(.alwaysTemplate)
            setImage(newImage, for: .normal)
            tintColor = color
        }
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        if let image = self.image {
            self.image = image.withRenderingMode(.alwaysTemplate)
            tintColor = color
        }
    }
}

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

extension UITextView {
    
    private func getAttributedString() -> NSMutableAttributedString {
        return attributedText.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
    }
    
    private func getRangeOfString(string: String) -> NSRange {
        return (text as NSString).range(of: string)
    }
    
    func setLineSpacing(lineSpacing: CGFloat) {
        
        if !text.isEmpty {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            
            let attributedString: NSMutableAttributedString = self.getAttributedString()
            
            attributedString.addAttribute(
                NSAttributedString.Key.paragraphStyle,
                value: paragraphStyle,
                range: getRangeOfString(string: text)
            )
            
            attributedText = attributedString
        }
    }
}

extension UIView {
    
    func drawBorder(color: UIColor = UIColor.red) {
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
    }
}
