//
//  MobileContentAccordionSectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAccordionSectionViewModel: MobileContentAccordionSectionViewModelType {
    
    private let sectionModel: Accordion.Section
    private let renderedPageContext: MobileContentRenderedPageContext
    
    required init(sectionModel: Accordion.Section, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.sectionModel = sectionModel
        self.renderedPageContext = renderedPageContext
    }
}
