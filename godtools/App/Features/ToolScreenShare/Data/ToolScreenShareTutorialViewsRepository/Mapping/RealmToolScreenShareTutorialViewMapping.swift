//
//  RealmToolScreenShareTutorialViewMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmToolScreenShareTutorialViewMapping: Mapping {
    
    func toDataModel(externalObject: ToolScreenShareTutorialViewDataModel) -> ToolScreenShareTutorialViewDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmToolScreenShareTutorialView) -> ToolScreenShareTutorialViewDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ToolScreenShareTutorialViewDataModel) -> RealmToolScreenShareTutorialView? {
        return RealmToolScreenShareTutorialView.createNewFrom(model: externalObject)
    }
}
