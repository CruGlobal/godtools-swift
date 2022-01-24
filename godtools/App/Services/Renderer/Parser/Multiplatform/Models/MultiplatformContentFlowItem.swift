//
//  MultiplatformContentFlowItem.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentFlowItem {
    
    private let flowItem: GodToolsToolParser.Flow.Item
    
    required init(flowItem: GodToolsToolParser.Flow.Item) {
        
        self.flowItem = flowItem
    }
}

extension MultiplatformContentFlowItem: MobileContentRenderableModel {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        var childModels: [MobileContentRenderableModel] = Array()
                    
        return childModels
    }
}
