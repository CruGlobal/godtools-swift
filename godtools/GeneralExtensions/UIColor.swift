//
//  UIColor.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static let gtWhite = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let gtBlue = UIColor(red: 59.0/255.0, green: 164.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    static let gtBlack = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    static let gtGrey = UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    static let gtGreyLight = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    static let gtRed = UIColor(red: 229.0/255.0, green: 91.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    static let gtGreen = UIColor(red: 110.0/255.0, green: 220.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    
    func colorWithoutTransparency() -> UIColor? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            if alpha == 1.0 {
                return self
            } else {
                let background: CGFloat = 255.0
                let red2: CGFloat = alpha * red + (1 - alpha) * background
                let green2: CGFloat = alpha * green + (1 - green) * background
                let blue2: CGFloat = alpha * blue + (1 - blue) * background
                return UIColor(red: red2/255.0, green: green2/255.0, blue: blue2/255.0, alpha: 1.0)
            }
        } else {
            return nil
        }
    }
    
}
