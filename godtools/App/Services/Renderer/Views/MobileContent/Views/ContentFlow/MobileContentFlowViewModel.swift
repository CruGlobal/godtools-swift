//
//  MobileContentFlowViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentFlowViewModel: MobileContentFlowViewModelType {
    
    private let contentFlow: GodToolsToolParser.Flow
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(contentFlow: GodToolsToolParser.Flow, rendererPageModel: MobileContentRendererPageModel) {
        
        self.contentFlow = contentFlow
        self.rendererPageModel = rendererPageModel        
    }
    
    var rowGravity: Gravity.Horizontal {
        return contentFlow.rowGravity
    }
}
