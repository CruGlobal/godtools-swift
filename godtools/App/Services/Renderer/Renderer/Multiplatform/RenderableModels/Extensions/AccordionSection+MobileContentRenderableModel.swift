//
//  AccordionSection+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Accordion.Section: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
        
        if let headerText = header {
            childModels.append(MultiplatformContentHeader(text: headerText))
        }
                
        addContentToChildModels(childModels: &childModels, content: content)
        
        return childModels
    }
}
