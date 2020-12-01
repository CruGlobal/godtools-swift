//
//  MobileContentRGBAColor.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

// Parses MobileContentApi String Color rgb(red,green,blue,alpha) into red, green, blue, alpha values.

struct MobileContentRGBAColor {
    
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    init(stringColor: String) {
        
        var valuesString: String = stringColor
        valuesString = valuesString.replacingOccurrences(of: "rgba(", with: "")
        valuesString = valuesString.replacingOccurrences(of: ")", with: "")
        
        let values: [String] = valuesString.components(separatedBy: ",")
        
        var red: CGFloat?
        var green: CGFloat?
        var blue: CGFloat?
        var alpha: CGFloat?
        
        for index in 0 ..< values.count {
            
            if index == 0 {
                red = MobileContentRGBAColor.convertStringValueToFloat(stringValue: values[index]) ?? 0
            }
            else if index == 1 {
                green = MobileContentRGBAColor.convertStringValueToFloat(stringValue: values[index]) ?? 0
            }
            else if index == 2 {
                blue = MobileContentRGBAColor.convertStringValueToFloat(stringValue: values[index]) ?? 0
            }
            else if index == 3 {
                alpha = MobileContentRGBAColor.convertStringValueToFloat(stringValue: values[index]) ?? 1
            }
        }
        
        self.red = red ?? 0
        self.green = green ?? 0
        self.blue = blue ?? 0
        self.alpha = alpha ?? 1
    }
    
    private static func convertStringValueToFloat(stringValue: String) -> CGFloat? {
        
        if let doubleValue = Double(stringValue) {
            return CGFloat(doubleValue)
        }
        
        return nil
    }
}

extension MobileContentRGBAColor {
    
    var color: UIColor {
        
        return UIColor(
            red: red / 255,
            green: green / 255,
            blue: blue / 255,
            alpha: alpha
        )
    }
}
