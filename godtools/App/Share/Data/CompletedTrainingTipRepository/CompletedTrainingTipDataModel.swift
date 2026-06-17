//
//  CompletedTrainingTipDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct CompletedTrainingTipDataModel: Sendable {
    
    let id: TrainingTipId
    
    init(id: TrainingTipId) {
        
        self.id = id
    }
}
