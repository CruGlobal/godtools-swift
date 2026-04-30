//
//  RealmCompletedTrainingTipMapping.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmCompletedTrainingTipMapping: Mapping {
    
    func toDataModel(externalObject: CompletedTrainingTipDataModel) -> CompletedTrainingTipDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmCompletedTrainingTip) -> CompletedTrainingTipDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: CompletedTrainingTipDataModel) -> RealmCompletedTrainingTip? {
        return RealmCompletedTrainingTip.createNewFrom(model: externalObject)
    }
}
