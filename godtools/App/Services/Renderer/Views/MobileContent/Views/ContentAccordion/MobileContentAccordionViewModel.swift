//
//  MobileContentAccordionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentAccordionViewModel: MobileContentAccordionViewModelType {
    
    private let accordionModel: ContentAccordionModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(accordionModel: ContentAccordionModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.accordionModel = accordionModel
        self.rendererPageModel = rendererPageModel
    }
}
