//
//  TrainingTipId.swift
//  godtools
//
//  Created by Levi Eggert on 6/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct TrainingTipId {
    
    let value: String
    let trainingTipId: String
    let languageId: String
    let resourceId: String
    
    init(trainingTipId: String, languageId: String, resourceId: String) {
        
        value = trainingTipId + "_" + resourceId + "_" + languageId
        
        self.trainingTipId = trainingTipId
        self.languageId = languageId
        self.resourceId = resourceId
    }
}
