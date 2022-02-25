//
//  InlineTip+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension InlineTip: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        var childModels: [AnyObject] = Array()
        
        if let tip = self.tip {
            childModels.append(tip)
        }
        
        return childModels
    }
}
