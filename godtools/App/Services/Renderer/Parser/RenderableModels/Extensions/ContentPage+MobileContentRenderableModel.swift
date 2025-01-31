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
                
        let multiplatformContent: MultiplatformContent = MultiplatformContent(
            content: content,
            contentInsets: nil,
            scrollIsEnabled: true
        )

        childModels.append(multiplatformContent)
        
        return childModels
    }
}
