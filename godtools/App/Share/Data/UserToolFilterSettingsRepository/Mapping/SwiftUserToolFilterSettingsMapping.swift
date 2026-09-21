//
//  SwiftUserToolFilterSettingsMapping.swift
//  godtools
//
//  Created by Rachael Skeath on 9/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserToolFilterSettingsMapping: Mapping {
    
    func toDataModel(externalObject: UserToolFilterSettingsDataModel) -> UserToolFilterSettingsDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftUserToolFilterSettings) -> UserToolFilterSettingsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolFilterSettingsDataModel) -> SwiftUserToolFilterSettings? {
        return SwiftUserToolFilterSettings.createNewFrom(model: externalObject)
    }
}
