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
    
    init(target: AnyObject, action: Selector, toggleVisibilityPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        super.init(
            controllerType: .base,
            itemData: NavBarItemData(
                contentType: .image(value: ImageCatalog.navClose.uiImage),
                style: nil,
                color: nil,
                target: target,
                action: action
            ),
            toggleVisibilityPublisher: toggleVisibilityPublisher
        )
    }
}
