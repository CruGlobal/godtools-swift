//
//  ColorPalette.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

enum ColorPalette: String {
    
    case gtBlue = "gtBlue"
    case gtGrey = "gtGrey"
    case gtLightGrey = "gtLightGrey"
    case gtLightestGrey = "gtLightestGrey"
    case progressBarBlue = "progressBarBlue"
    case banner = "banner"
    
    var colorName: String {
        return rawValue
    }
    
    var color: Color {
                
        return Color(colorName, bundle: Bundle.main)
    }
    
    static func getColorWithRGB(red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) -> Color {
        Color(.sRGB, red: red / 255, green: green / 255, blue: blue / 255, opacity: opacity)
    }
    
    static func getUIColorWithRGB(red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) -> UIColor {        
        return UIColor(ColorPalette.getColorWithRGB(red: red, green: green, blue: blue, opacity: opacity))
    }
    
    var uiColor: UIColor {
                
        if let color = UIColor(named: colorName, in: Bundle.main, compatibleWith: nil) {
            return color
        }
        
        assertionFailure("Failed to find color with name: \(colorName), returning UIColor.black")
        
        return UIColor.black
    }
}
