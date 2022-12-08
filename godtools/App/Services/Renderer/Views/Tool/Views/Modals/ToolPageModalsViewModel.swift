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
    private let renderedPageContext: MobileContentRenderedPageContext
    
    required init(modals: [Modal], renderedPageContext: MobileContentRenderedPageContext) {
        
        self.modals = modals
        self.renderedPageContext = renderedPageContext
        
        super.init(baseModels: modals)
    }
}
