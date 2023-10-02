//
//  AppLayoutDirectionBasedBarButtonItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class AppLayoutDirectionBasedBarButtonItem {
    
    let leftToRightImage: UIImage?
    let rightToLeftImage: UIImage?
    let style: UIBarButtonItem.Style?
    let color: UIColor?
    let target: AnyObject
    let action: Selector
    
    init(leftToRightImage: UIImage?, rightToLeftImage: UIImage?, style: UIBarButtonItem.Style?, color: UIColor?, target: AnyObject, action: Selector) {
        
        self.leftToRightImage = leftToRightImage
        self.rightToLeftImage = rightToLeftImage
        self.style = style
        self.color = color
        self.target = target
        self.action = action
    }
    
    func getNewBarButtonItemForLayoutDirection(direction: ApplicationLayoutDirection) -> UIBarButtonItem {
        
        let image: UIImage?
        
        switch direction {
        case .leftToRight:
            image = leftToRightImage
        case .rightToLeft:
            image = rightToLeftImage
        }
        
        let buttonItem = UIBarButtonItem(image: image, style: style ?? .plain, target: target, action: action)
        
        if let color = color {
            buttonItem.tintColor = color
        }
        
        return buttonItem
    }
}
