//
//  UIImageView+ImageColor.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 12/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

public extension UIImageView {
    
    func setImageColor(color: UIColor) {
        
        guard let currentImage = self.image else {
            return
        }
        
        image = currentImage.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}
