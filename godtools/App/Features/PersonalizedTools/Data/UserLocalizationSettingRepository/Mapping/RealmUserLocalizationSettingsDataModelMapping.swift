//
//  RealmUserLocalizationSettingsDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserLocalizationSettingsDataModelMapping: Mapping {
    
    func toDataModel(externalObject: UserLocalizationSettingsDataModel) -> UserLocalizationSettingsDataModel? {
        return UserLocalizationSettingsDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmUserLocalizationSettings) -> UserLocalizationSettingsDataModel? {
        return UserLocalizationSettingsDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: UserLocalizationSettingsDataModel) -> RealmUserLocalizationSettings? {
        return RealmUserLocalizationSettings.createNewFrom(interface: externalObject)
    }
}
