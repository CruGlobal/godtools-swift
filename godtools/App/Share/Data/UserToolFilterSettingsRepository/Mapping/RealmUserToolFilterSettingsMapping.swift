//
//  RealmUserToolFilterSettingsMapping.swift
//  godtools
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserToolFilterSettingsMapping: Mapping {
    
    func toDataModel(externalObject: UserToolFilterSettingsDataModel) -> UserToolFilterSettingsDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmUserToolFilterSettings) -> UserToolFilterSettingsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolFilterSettingsDataModel) -> RealmUserToolFilterSettings? {
        return RealmUserToolFilterSettings.createNewFrom(model: externalObject)
    }
}
