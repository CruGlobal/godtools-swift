//
//  AppBackBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppBackBarItem: AppLayoutDirectionBasedBarItem {
    
    init(target: AnyObject, action: Selector, accessibilityIdentifier: String?, hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil, layoutDirectionPublisher: AnyPublisher<UISemanticContentAttribute, Never>? = nil) {
        
        super.init(
            leftToRightImage: ImageCatalog.navBack.uiImage,
            rightToLeftImage: ImageCatalog.navBackFlipped.uiImage,
            color: nil,
            target: target,
            action: action,
            accessibilityIdentifier: accessibilityIdentifier,
            hidesBarItemPublisher: hidesBarItemPublisher,
            layoutDirectionPublisher: layoutDirectionPublisher
        )
    }
}
