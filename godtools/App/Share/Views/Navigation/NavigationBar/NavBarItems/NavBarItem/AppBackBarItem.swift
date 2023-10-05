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
    
    init(target: AnyObject, action: Selector, toggleVisibilityPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        super.init(
            leftToRightImage: ImageCatalog.navBack.uiImage,
            rightToLeftImage: ImageCatalog.navBackFlipped.uiImage,
            style: .plain,
            color: nil,
            target: target,
            action: action,
            toggleVisibilityPublisher: toggleVisibilityPublisher
        )
    }
}
