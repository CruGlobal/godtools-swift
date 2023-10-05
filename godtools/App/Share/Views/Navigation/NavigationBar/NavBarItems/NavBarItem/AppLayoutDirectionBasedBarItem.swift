//
//  AppLayoutDirectionBasedBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppLayoutDirectionBasedBarItem: NavBarItem {
    
    let leftToRightImage: UIImage?
    let rightToLeftImage: UIImage?
    
    init(leftToRightImage: UIImage?, rightToLeftImage: UIImage?, style: UIBarButtonItem.Style?, color: UIColor?, target: AnyObject, action: Selector, accessibilityIdentifier: String?, toggleVisibilityPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        self.leftToRightImage = leftToRightImage
        self.rightToLeftImage = rightToLeftImage
        
        super.init(
            controllerType: .appLayoutDirection,
            itemData: NavBarItemData(
                contentType: .image(value: leftToRightImage),
                style: style,
                color: color,
                target: target,
                action: action,
                accessibilityIdentifier: accessibilityIdentifier
            ),
            toggleVisibilityPublisher: toggleVisibilityPublisher
        )
    }
}
