//
//  CompletedTrainingTipDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct CompletedTrainingTipDataModel {
    
    let id: String
    let trainingTipId: String
    let languageId: String
    let resourceId: String
    
    init(trainingTipDomainModel: TrainingTipDomainModel) {
        
        id = trainingTipDomainModel.id
        trainingTipId = trainingTipDomainModel.trainingTipId
        languageId = trainingTipDomainModel.languageId
        resourceId = trainingTipDomainModel.resourceId
    }
    
    init(realmCompletedTrainingTip: RealmCompletedTrainingTip) {
        
        id = realmCompletedTrainingTip.id
        trainingTipId = realmCompletedTrainingTip.trainingTipId
        languageId = realmCompletedTrainingTip.languageId
        resourceId = realmCompletedTrainingTip.resourceId
    }
}
