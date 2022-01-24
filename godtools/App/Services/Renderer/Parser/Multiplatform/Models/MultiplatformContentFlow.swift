//
//  MultiplatformContentFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentFlow {
    
    private let contentFlow: GodToolsToolParser.Flow
    
    required init(contentFlow: GodToolsToolParser.Flow) {
        
        self.contentFlow = contentFlow
    }
}

extension MultiplatformContentFlow: MobileContentRenderableModel {
    
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
            
        let flowItems: [MultiplatformContentFlowItem] = contentFlow.items.map({MultiplatformContentFlowItem(flowItem: $0)})

        childModels.append(contentsOf: flowItems)
        
        return childModels
    }
}
