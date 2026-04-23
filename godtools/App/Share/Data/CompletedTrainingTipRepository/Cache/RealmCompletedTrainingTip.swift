//
//  RealmCompletedTrainingTip.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmCompletedTrainingTip: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var trainingTipId: String = ""
    @objc dynamic var resourceId: String = ""
    @objc dynamic var languageId: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmCompletedTrainingTip {
    
    func mapFrom(model: CompletedTrainingTipDataModel) {
        
        id = model.id
        trainingTipId = model.trainingTipId
        resourceId = model.resourceId
        languageId = model.languageId
    }
    
    static func createNewFrom(model: CompletedTrainingTipDataModel) -> RealmCompletedTrainingTip {
        let object = RealmCompletedTrainingTip()
        object.mapFrom(model: model)
        return object
    }
   
    func toModel() -> CompletedTrainingTipDataModel {
        return CompletedTrainingTipDataModel(
            id: id,
            trainingTipId: trainingTipId,
            languageId: languageId,
            resourceId: resourceId
        )
    }
}
