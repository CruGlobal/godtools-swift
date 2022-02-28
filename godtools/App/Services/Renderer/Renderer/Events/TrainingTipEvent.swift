//
//  TrainingTipEvent.swift
//  godtools
//
//  Created by Levi Eggert on 11/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class TrainingTipEvent {
    
    let renderedPageContext: MobileContentRenderedPageContext
    let trainingTipId: String
    let tipModel: Tip
    
    required init(renderedPageContext: MobileContentRenderedPageContext, trainingTipId: String, tipModel: Tip) {
        
        self.renderedPageContext = renderedPageContext
        self.trainingTipId = trainingTipId
        self.tipModel = tipModel
    }
}
