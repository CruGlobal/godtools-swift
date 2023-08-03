//
//  ToolPageModalsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ToolPageModalsViewModel: MobileContentViewModel {
    
    private let modals: [Modal]
    
    init(modals: [Modal], renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.modals = modals
        
        super.init(baseModels: modals, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
