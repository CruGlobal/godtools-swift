//
//  TrainingPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class TrainingPageViewModel: TrainingPageViewModelType {
    
    private let pageModel: TipPage
    private let renderedPageContext: MobileContentRenderedPageContext
    
    required init(pageModel: TipPage, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.pageModel = pageModel
        self.renderedPageContext = renderedPageContext
    }
}
