//
//  AppShareBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit
import Combine

class AppShareBarItem: NavBarItem {
    
    init(color: UIColor?, target: AnyObject, action: Selector, accessibilityIdentifier: String?, hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        super.init(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .image(value: ImageCatalog.navShare.uiImage),
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
