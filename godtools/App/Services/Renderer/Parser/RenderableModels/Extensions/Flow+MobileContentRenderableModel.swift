//
//  Flow+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension GodToolsToolParser.Flow: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        return items
    }
}
