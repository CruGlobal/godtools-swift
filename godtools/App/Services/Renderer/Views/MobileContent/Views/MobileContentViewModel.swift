//
//  MobileContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentViewModel: NSObject {
    
    let baseModel: BaseModel?
    let baseModels: [BaseModel]
    let renderedPageContext: MobileContentRenderedPageContext
    
    init(baseModel: BaseModel?, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.baseModel = baseModel
        
        if let baseModel = baseModel {
            self.baseModels = [baseModel]
        }
        else {
            self.baseModels = Array()
        }
        
        self.renderedPageContext = renderedPageContext
                
        super.init()
    }
    
    init(baseModels: [BaseModel], renderedPageContext: MobileContentRenderedPageContext) {
        
        self.baseModel = baseModels.first
        self.baseModels = baseModels
        
        self.renderedPageContext = renderedPageContext
        
        super.init()
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
}
