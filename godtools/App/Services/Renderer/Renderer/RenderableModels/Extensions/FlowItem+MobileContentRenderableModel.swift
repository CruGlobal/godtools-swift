//
//  FlowItem+MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

extension GodToolsToolParser.Flow.Item: MobileContentRenderableModel {
    
    func getRenderableChildModels() -> [Any] {
        
        return content
    }
}
