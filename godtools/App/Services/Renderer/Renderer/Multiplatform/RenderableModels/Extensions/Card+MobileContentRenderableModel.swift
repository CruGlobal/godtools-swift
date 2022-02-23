//
//  Card+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Card: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
                
        addContentToChildModels(childModels: &childModels, content: content)
                    
        return childModels
    }
}
