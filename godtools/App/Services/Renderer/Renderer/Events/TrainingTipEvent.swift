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
    
    let rendererPageModel: MobileContentRendererPageModel
    let trainingTipId: String
    let tipModel: Tip
    
    required init(rendererPageModel: MobileContentRendererPageModel, trainingTipId: String, tipModel: Tip) {
        
        self.rendererPageModel = rendererPageModel
        self.trainingTipId = trainingTipId
        self.tipModel = tipModel
    }
}
