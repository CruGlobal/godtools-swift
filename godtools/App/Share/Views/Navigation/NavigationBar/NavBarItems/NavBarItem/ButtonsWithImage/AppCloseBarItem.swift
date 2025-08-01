//
//  AppCloseBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppCloseBarItem: NavBarItem {
    
    init(color: UIColor?, target: AnyObject, action: Selector, accessibilityIdentifier: String? = AccessibilityStrings.Button.close.rawValue, hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        super.init(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .image(value: ImageCatalog.navClose.uiImage),
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
