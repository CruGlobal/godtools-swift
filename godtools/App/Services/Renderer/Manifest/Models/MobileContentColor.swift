//
//  MobileContentColor.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

// TODO: This can be removed once fully switching to use multiplatform xml parser for manifest xmls. ~Levi
class MobileContentColor {
        
    let uiColor: UIColor
    
    required init(color: UIColor) {
        
        self.uiColor = color
    }
    
    required init(stringColor: String) {
        
        // Parses MobileContentApi String Color rgb(red,green,blue,alpha) into red, green, blue, alpha values.
        
        var valuesString: String = stringColor
        valuesString = valuesString.replacingOccurrences(of: "rgba(", with: "")
        valuesString = valuesString.replacingOccurrences(of: ")", with: "")
        
        let values: [String] = valuesString.components(separatedBy: ",")
        
        var redOptionalValue: CGFloat?
        var greenOptionalValue: CGFloat?
        var blueOptionalValue: CGFloat?
        var alphaOptionalValue: CGFloat?
        
        for index in 0 ..< values.count {
            
            if index == 0 {
                redOptionalValue = MobileContentColor.convertStringValueToFloat(stringValue: values[index]) ?? 0
            }
            else if index == 1 {
                greenOptionalValue = MobileContentColor.convertStringValueToFloat(stringValue: values[index]) ?? 0
            }
            else if index == 2 {
                blueOptionalValue = MobileContentColor.convertStringValueToFloat(stringValue: values[index]) ?? 0
            }
            else if index == 3 {
                alphaOptionalValue = MobileContentColor.convertStringValueToFloat(stringValue: values[index]) ?? 1
            }
        }
        
        let redValue: CGFloat = redOptionalValue ?? 0
        let greenValue: CGFloat = greenOptionalValue ?? 0
        let blueValue: CGFloat = blueOptionalValue ?? 0
        let alphaValue: CGFloat = alphaOptionalValue ?? 1
                
        self.uiColor = UIColor(
            red: redValue / 255,
            green: greenValue / 255,
            blue: blueValue / 255,
            alpha: alphaValue
        )
    }
    
    private static func convertStringValueToFloat(stringValue: String) -> CGFloat? {
        
        if let doubleValue = Double(stringValue) {
            return CGFloat(doubleValue)
        }
        
        return nil
    }
}
