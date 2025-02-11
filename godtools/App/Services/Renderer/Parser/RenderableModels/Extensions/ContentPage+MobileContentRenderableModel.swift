//
//  ContentPage.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

extension ContentPage: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()
        
        let contentPageHorizontalInsets: CGFloat = 16
        
        let multiplatformContent: MultiplatformContent = MultiplatformContent(
            content: content,
            contentInsets: UIEdgeInsets(top: 0, left: contentPageHorizontalInsets, bottom: 0, right: contentPageHorizontalInsets),
            scrollIsEnabled: true
        )

        childModels.append(multiplatformContent)
        
        return childModels
    }
}
