//
//  AppHomeBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit
import Combine

class AppHomeBarItem: NavBarItem {
    
    init(color: UIColor?, target: AnyObject, action: Selector, accessibilityIdentifier: String?, hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        super.init(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .image(value: ImageCatalog.navHome.uiImage),
                style: nil,
                color: color,
                target: target,
                action: action,
                accessibilityIdentifier: accessibilityIdentifier
            ),
            hidesBarItemPublisher: hidesBarItemPublisher
        )
    }
}
