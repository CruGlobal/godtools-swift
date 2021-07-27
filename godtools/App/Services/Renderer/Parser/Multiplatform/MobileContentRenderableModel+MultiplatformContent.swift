//
//  MobileContentRenderableModel+MultiplatformContent.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension MobileContentRenderableModel {
    
    func addContentToChildModels(childModels: inout [MobileContentRenderableModel], content: [Content]) {
        
        for content in content {
            if let renderableModel = MultiplatformContentFactory.getRenderableModel(content: content) {
                childModels.append(renderableModel)
            }
        }
    }
}
