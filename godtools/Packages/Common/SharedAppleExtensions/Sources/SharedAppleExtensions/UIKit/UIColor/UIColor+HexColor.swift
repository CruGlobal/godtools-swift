//
//  UIColor+HexColor.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

public extension UIColor {
    
    static func hexColor(hexValue: Int, alpha: CGFloat = 1) -> UIColor {
        let red: Int = (hexValue >> 16) & 0xff
        let green: Int = (hexValue >> 8) & 0xff
        let blue: Int = hexValue & 0xff
        
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
