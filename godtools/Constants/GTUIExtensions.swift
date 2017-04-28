//
//  GTConstants.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let gtWhite = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let gtBlue = UIColor(red: 50.0/255.0, green: 164.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    static let gtBlack = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    static let gtGrey = UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    static let gtGreyLight = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    static let gtRed = UIColor(red: 229.0/255.0, green: 91.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    static let gtGreen = UIColor(red: 110.0/255.0, green: 220.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    
}

extension UIFont {
    
    static func gtRegular(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)
    }
    
    static func gtLight(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
    }
    
    static func gtThin(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightThin)
    }
    
    static func gtSemiBold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightSemibold)
    }
    
}
