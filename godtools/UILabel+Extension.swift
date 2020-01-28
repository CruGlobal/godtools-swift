//
//  UILabel+Extension.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UILabel {
    
    private func getAttributedString() -> NSMutableAttributedString {
        return attributedText?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
    }
    
    private func getRangeOfString(string: String) -> NSRange {
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
