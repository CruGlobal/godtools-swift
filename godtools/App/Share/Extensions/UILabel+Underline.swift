//
//  UILabel+Underline.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

extension UILabel {
    
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
