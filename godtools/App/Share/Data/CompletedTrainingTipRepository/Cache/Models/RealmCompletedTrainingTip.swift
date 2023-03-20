//
//  RealmCompletedTrainingTip.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCompletedTrainingTip: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var trainingTipId: String = ""
    @objc dynamic var resourceId: String = ""
    @objc dynamic var languageId: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: CompletedTrainingTipDataModel) {
        
        id = model.id
        trainingTipId = model.trainingTipId
        resourceId = model.resourceId
        languageId = model.languageId
    }
}
