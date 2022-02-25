//
//  Card+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension Card: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [AnyObject] {
        
        return content
    }
}
