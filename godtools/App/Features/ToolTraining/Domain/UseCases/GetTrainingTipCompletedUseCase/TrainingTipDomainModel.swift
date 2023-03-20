//
//  TrainingTipDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 3/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TrainingTipDomainModel {
    
    let trainingTipId: String
    let resourceId: String
    let languageId: String
    
    var id: String {
        return trainingTipId + "_" + resourceId + "_" + languageId
    }
}
