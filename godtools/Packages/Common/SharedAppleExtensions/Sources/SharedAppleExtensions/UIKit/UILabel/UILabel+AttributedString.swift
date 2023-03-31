//
//  UILabel+AttributedString.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 9/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

public extension UILabel {
    
    private func getAttributedString() -> NSMutableAttributedString {
       
        return attributedText?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
    }
    
    private func getRangeOfString(string: String) -> NSRange {
       
        guard let text = self.text else {
            return NSMakeRange(0, 0)
        }
        
        return (text as NSString).range(of: string)
    }
    
    func setLineSpacing(lineSpacing: CGFloat) {
        
        guard let text = self.text, !text.isEmpty else {
            return
        }
        
        let currTextAlignment: NSTextAlignment = textAlignment
        let attributedString: NSMutableAttributedString = getAttributedString()
        let range: NSRange = getRangeOfString(string: text)
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = lineSpacing
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        
        attributedText = attributedString
        textAlignment = currTextAlignment
    }
    
    func underline(labelText: String) {
        
        self.text = labelText
        
        let textRange = NSRange(location: 0, length: labelText.count)
        let attributedText = NSMutableAttributedString(string: labelText)
        
        attributedText.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: textRange
        )

        self.attributedText = attributedText
    }
}
