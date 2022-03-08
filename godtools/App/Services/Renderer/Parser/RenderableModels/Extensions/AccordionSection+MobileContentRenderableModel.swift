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
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()
        
        if let headerText = header {
            childModels.append(MultiplatformContentHeader(text: headerText))
        }
        
        childModels.append(contentsOf: content)
                                
        return childModels
    }
}
