//
//  RealmUserLocalizationSettingsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserLocalizationSettingsMapping: Mapping {
    
    func toDataModel(externalObject: UserLocalizationSettingsDataModel) -> UserLocalizationSettingsDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmUserLocalizationSettings) -> UserLocalizationSettingsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserLocalizationSettingsDataModel) -> RealmUserLocalizationSettings? {
        return RealmUserLocalizationSettings.createNewFrom(model: externalObject)
    }
}
