//
//  Hero+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Hero: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        if let heading = heading {
            childModels.append(MultiplatformHeading(text: heading))
        }
        
        addContentToChildModels(childModels: &childModels, content: content)
             
        return childModels
    }
}
