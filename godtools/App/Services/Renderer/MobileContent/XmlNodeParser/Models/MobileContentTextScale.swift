//
//  MobileContentTextScale.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentTextScale {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    let stringValue: String?
    let floatValue: CGFloat
    
    required init(textScale: String?) {
        
        self.stringValue = textScale
        self.floatValue = MobileContentTextScale.getFloatValue(textScale: textScale)
    }
    
    private static func getFloatValue(textScale: String?) -> CGFloat {
        
        let textScaleFloatValue: CGFloat
        
        if let textScaleString = textScale,
           let number = MobileContentTextScale.numberFormatter.number(from: textScaleString) {
            
            textScaleFloatValue = CGFloat(truncating: number)
        }
        else {
            
            textScaleFloatValue = 1
        }
        
        return textScaleFloatValue
    }
}
