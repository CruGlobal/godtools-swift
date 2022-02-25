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
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()
        
        if let heading = heading {
            childModels.append(MultiplatformHeading(text: heading))
        }
        
        childModels.append(contentsOf: content)
                     
        return childModels
    }
}
