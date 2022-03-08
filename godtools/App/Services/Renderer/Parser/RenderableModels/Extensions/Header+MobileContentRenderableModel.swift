//
//  Header+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Header: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()
        
        if let tip = tip {
            childModels.append(tip)
        }
        
        return childModels
    }
}
