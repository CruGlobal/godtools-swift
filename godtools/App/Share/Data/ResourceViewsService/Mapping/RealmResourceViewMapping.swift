//
//  RealmResourceViewMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmResourceViewMapping: Mapping {
    
    func toDataModel(externalObject: ResourceViewDataModel) -> ResourceViewDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmResourceView) -> ResourceViewDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ResourceViewDataModel) -> RealmResourceView? {
        return RealmResourceView.createNewFrom(model: externalObject)
    }
}
