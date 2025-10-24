//
//  MobileContentFlowViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class MobileContentFlowViewModel: MobileContentViewModel {
    
    private let contentFlow: GodToolsShared.Flow
    
    init(contentFlow: GodToolsShared.Flow, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
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
