//
//  SwiftUserLocalizationSettingsDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserLocalizationSettingsDataModelMapping: Mapping {
    
    func toDataModel(externalObject: UserLocalizationSettingsDataModel) -> UserLocalizationSettingsDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftUserLocalizationSettings) -> UserLocalizationSettingsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserLocalizationSettingsDataModel) -> SwiftUserLocalizationSettings? {
        return SwiftUserLocalizationSettings.createNewFrom(model: externalObject)
    }
}
