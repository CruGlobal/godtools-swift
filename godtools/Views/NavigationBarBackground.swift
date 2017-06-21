//
//  File.swift
//  godtools
//
//  Created by Ryan Carlson on 6/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class NavigationBarBackground {
    static func createFrom(color: UIColor) -> UIImage {
        let color = color.cgColor
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(1.0), height: CGFloat(1.0)), false, CGFloat(2.0))
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color)
        context?.fill(rect)
        context?.saveGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
