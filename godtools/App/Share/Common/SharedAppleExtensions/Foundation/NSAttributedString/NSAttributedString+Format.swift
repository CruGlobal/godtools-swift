//
//  NSAttributedString+Format.swift
//  godtools
//
//  Created by Rachael Skeath on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    convenience init(format: NSAttributedString, args: NSAttributedString...) {
        let mutableNSAttributedString = NSMutableAttributedString(attributedString: format)

        args.forEach { attributedStringArg in
            let range = NSString(string: mutableNSAttributedString.string).range(of: "%@")
            
            if range.lowerBound >= 0 && range.upperBound < mutableNSAttributedString.length && range.length > 0 {
                
                mutableNSAttributedString.replaceCharacters(in: range, with: attributedStringArg)
            }
        }
    
        self.init(attributedString: mutableNSAttributedString)
    }
}
