//
//  UIView+DrawBorder.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

public extension UIView {
    
    func drawBorder(color: UIColor = UIColor.red) {
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
    }
}
