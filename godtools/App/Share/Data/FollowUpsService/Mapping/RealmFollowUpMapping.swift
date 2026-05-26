//
//  RealmFollowUpMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmFollowUpMapping: Mapping {
    
    func toDataModel(externalObject: FollowUpDataModel) -> FollowUpDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmFollowUp) -> FollowUpDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: FollowUpDataModel) -> RealmFollowUp? {
        return RealmFollowUp.createNewFrom(model: externalObject)
    }
}
