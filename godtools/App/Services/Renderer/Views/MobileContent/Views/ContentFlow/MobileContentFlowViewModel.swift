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
    
    init(contentFlow: GodToolsToolParser.Flow, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.contentFlow = contentFlow
        
        super.init(baseModel: contentFlow, renderedPageContext: renderedPageContext)
    }
    
    var rowGravity: Gravity.Horizontal {
        return contentFlow.rowGravity
    }
}
