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
    
    init(contentFlow: GodToolsToolParser.Flow, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.contentFlow = contentFlow
        
        super.init(baseModel: contentFlow, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    var rowGravity: Gravity.Horizontal {
        return contentFlow.rowGravity
    }
    
    var layoutDirection: ApplicationLayoutDirection {
        return renderedPageContext.primaryLanguageLayoutDirection
    }
}
