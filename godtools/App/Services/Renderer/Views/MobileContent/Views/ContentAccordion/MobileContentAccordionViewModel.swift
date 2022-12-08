//
//  MobileContentAccordionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAccordionViewModel: MobileContentViewModel {
    
    private let accordionModel: Accordion
    private let renderedPageContext: MobileContentRenderedPageContext
    
    init(accordionModel: Accordion, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.accordionModel = accordionModel
        self.renderedPageContext = renderedPageContext
        
        super.init(baseModel: accordionModel)
    }
}
