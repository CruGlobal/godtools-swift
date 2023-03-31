//
//  UITextView+AttributedString.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 10/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

public extension UITextView {
    
    private func getAttributedString() -> NSMutableAttributedString {
        return attributedText.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
    }
    
    private func getRangeOfString(string: String) -> NSRange {
        return (text as NSString).range(of: string)
    }
    
    func setLineSpacing(lineSpacing: CGFloat) {
        
        guard !text.isEmpty else {
            return
        }
        
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
