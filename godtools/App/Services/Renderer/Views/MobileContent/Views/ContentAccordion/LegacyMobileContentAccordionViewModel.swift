//
//  LegacyMobileContentAccordionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class LegacyMobileContentAccordionViewModel: LegacyMobileContentViewModel {
    
    private let accordionModel: Accordion
    
    init(
        accordionModel: Accordion,
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics
    ) {
        
        self.accordionModel = accordionModel
        
        super.init(baseModel: accordionModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
