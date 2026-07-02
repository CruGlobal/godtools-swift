//
//  SwiftUserToolSettingsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserToolSettingsMapping: Mapping {
    
    func toDataModel(externalObject: UserToolSettingsDataModel) -> UserToolSettingsDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftUserToolSettings) -> UserToolSettingsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolSettingsDataModel) -> SwiftUserToolSettings? {
        return SwiftUserToolSettings.createNewFrom(model: externalObject)
    }
}
