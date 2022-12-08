//
//  MobileContentFlowViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentFlowViewModel: MobileContentViewModel {
    
    private let contentFlow: GodToolsToolParser.Flow
    private let renderedPageContext: MobileContentRenderedPageContext
    
    init(contentFlow: GodToolsToolParser.Flow, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.contentFlow = contentFlow
        self.renderedPageContext = renderedPageContext
        
        super.init(baseModel: contentFlow)
    }
    
    var rowGravity: Gravity.Horizontal {
        return contentFlow.rowGravity
    }
}
