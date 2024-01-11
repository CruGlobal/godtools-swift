//
//  AppLanguageSettingsBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppLanguageSettingsBarItem: NavBarItem {
    
    init(color: UIColor?, target: AnyObject, action: Selector, accessibilityIdentifier: String?, hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        super.init(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .image(value: ImageCatalog.navLanguage.uiImage),
                style: .plain,
                color: color,
                target: target,
                action: action,
                accessibilityIdentifier: accessibilityIdentifier
            ),
            hidesBarItemPublisher: hidesBarItemPublisher
        )
    }
}
