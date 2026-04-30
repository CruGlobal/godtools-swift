//
//  RealmUserToolSettingsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserToolSettingsMapping: Mapping {
    
    func toDataModel(externalObject: UserToolSettingsDataModel) -> UserToolSettingsDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmUserToolSettings) -> UserToolSettingsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolSettingsDataModel) -> RealmUserToolSettings? {
        return RealmUserToolSettings.createNewFrom(model: externalObject)
    }
}
