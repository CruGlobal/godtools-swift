//
//  TipPage+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension TipPage: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        return content
    }
}
