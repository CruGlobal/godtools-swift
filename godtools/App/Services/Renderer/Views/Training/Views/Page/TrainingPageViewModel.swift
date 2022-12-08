//
//  TrainingPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class TrainingPageViewModel: MobileContentViewModel {
    
    private let pageModel: TipPage
    
    required init(pageModel: TipPage, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.pageModel = pageModel
        
        super.init(baseModel: pageModel, renderedPageContext: renderedPageContext)
    }
}
