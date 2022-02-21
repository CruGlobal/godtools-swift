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
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
                
        var childModels: [MobileContentRenderableModel] = Array()
        
        if let number = number {
            childModels.append(MultiplatformNumber(text: number))
        }
        
        if let title = title {
            childModels.append(MultiplatformTitle(text: title))
        }
        
        if let trainingTip = tip {
            childModels.append(trainingTip)
        }
        
        return childModels
    }
}
