//
//  ColorPalette.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit

enum ColorPalette {
    
    static let bannerColor: UIColor = UIColor(red: 219 / 255, green: 243 / 255, blue: 255 / 255, alpha: 1)
    
    case gtBlue
    case primaryNavBar
    
    var color: UIColor {
        switch self {
        case .gtBlue:
            return getGtBlueColor()
        case .primaryNavBar:
            return getGtBlueColor()
        }
    }
    
    private func getGtBlueColor() -> UIColor {
        return UIColor(red: 59.0/255.0, green: 164.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    }
}
