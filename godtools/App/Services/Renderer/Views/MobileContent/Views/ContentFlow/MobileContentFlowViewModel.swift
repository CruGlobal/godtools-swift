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
    private let renderedPageContext: MobileContentRenderedPageContext
    
    required init(contentFlow: GodToolsToolParser.Flow, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.contentFlow = contentFlow
        self.renderedPageContext = renderedPageContext        
    }
    
    var rowGravity: Gravity.Horizontal {
        return contentFlow.rowGravity
    }
}
