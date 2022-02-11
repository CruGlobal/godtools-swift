//
//  MobileContentAccordionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAccordionViewModel: MobileContentAccordionViewModelType {
    
    private let accordionModel: Accordion
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(accordionModel: Accordion, rendererPageModel: MobileContentRendererPageModel) {
        
        self.accordionModel = accordionModel
        self.rendererPageModel = rendererPageModel
    }
}
