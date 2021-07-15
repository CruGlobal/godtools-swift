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
    private let pageModel: MobileContentRendererPageModel
    
    required init(accordionModel: ContentAccordionModelType, pageModel: MobileContentRendererPageModel) {
        
        self.accordionModel = accordionModel
        self.pageModel = pageModel
    }
}
