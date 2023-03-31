//
//  UIButton+ImageColor.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 3/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

public extension UIButton {
    
    func setImageColor(color: UIColor) {
        
        guard let currentImage = self.image(for: .normal) else {
            return
        }
        
        let newImage: UIImage = currentImage.withRenderingMode(.alwaysTemplate)
        setImage(newImage, for: .normal)
        tintColor = color
    }
}
