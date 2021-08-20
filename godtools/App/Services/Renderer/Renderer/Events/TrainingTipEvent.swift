//
//  TrainingTipEvent.swift
//  godtools
//
//  Created by Levi Eggert on 11/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TrainingTipEvent {
    
    let rendererPageModel: MobileContentRendererPageModel
    let trainingTipId: String
    let tipModel: TipModelType
    
    required init(rendererPageModel: MobileContentRendererPageModel, trainingTipId: String, tipModel: TipModelType) {
        
        self.rendererPageModel = rendererPageModel
        self.trainingTipId = trainingTipId
        self.tipModel = tipModel
    }
}
