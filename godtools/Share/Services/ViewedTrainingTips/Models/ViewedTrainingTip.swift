//
//  ViewedTrainingTip.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ViewedTrainingTip: ViewedTrainingTipType {
    
    let trainingTipId: String
    let resourceId: String
    let languageId: String
    
    var id: String {
        return trainingTipId + "_" + resourceId + "_" + languageId
    }
}
