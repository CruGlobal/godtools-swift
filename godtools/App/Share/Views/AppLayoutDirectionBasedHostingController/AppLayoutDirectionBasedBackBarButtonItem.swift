//
//  AppLayoutDirectionBasedBackBarButtonItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class AppLayoutDirectionBasedBackBarButtonItem: AppLayoutDirectionBasedBarButtonItem {
    
    init(target: AnyObject, action: Selector) {
        
        super.init(
            leftToRightImage: ImageCatalog.navBack.uiImage,
            rightToLeftImage: ImageCatalog.navBackFlipped.uiImage,
            style: .plain,
            color: nil,
            target: target,
            action: action
        )
    }
}
