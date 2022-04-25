//
//  UIImage+CreateImageWithColor.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func createImageWithColor(color: UIColor) -> UIImage? {
        
        let cgColor: CGColor = color.cgColor
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(1.0), height: CGFloat(1.0)), false, CGFloat(2.0))
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(cgColor)
        context?.fill(rect)
        context?.saveGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }
}
