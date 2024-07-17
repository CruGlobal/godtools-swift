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
    
    var uiColor: UIColor {
                
        if let color = UIColor(named: colorName, in: Bundle.main, compatibleWith: nil) {
            return color
        }
        
        assertionFailure("Failed to find color with name: \(colorName), returning UIColor.black")
        
        return UIColor.black
    }
}
