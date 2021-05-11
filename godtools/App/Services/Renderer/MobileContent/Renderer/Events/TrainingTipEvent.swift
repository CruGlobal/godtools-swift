//
//  TrainingTipEvent.swift
//  godtools
//
//  Created by Levi Eggert on 11/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TrainingTipEvent {
    
    let pageModel: MobileContentRendererPageModel
    let trainingTipId: String
    let tipNode: TipNode
    
    required init(pageModel: MobileContentRendererPageModel, trainingTipId: String, tipNode: TipNode) {
        
        self.pageModel = pageModel
        self.trainingTipId = trainingTipId
        self.tipNode = tipNode
    }
}
