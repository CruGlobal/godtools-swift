//
//  UIView+DrawBorder.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIView {
    
    func drawBorder(color: UIColor = UIColor.red, width: CGFloat = 1) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}
