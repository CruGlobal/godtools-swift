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
    
    func getRenderableChildModels() -> [Any] {
        
        var childModels: [Any] = Array()
        
        if let heading = heading {
            childModels.append(MultiplatformHeading(text: heading))
        }
        
        childModels.append(contentsOf: content)
                     
        return childModels
    }
}
