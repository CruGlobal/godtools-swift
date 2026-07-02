//
//  SwiftUserToolLanguageFilterMapping.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserToolLanguageFilterMapping: Mapping {
    
    func toDataModel(externalObject: UserToolLanguageFilterDataModel) -> UserToolLanguageFilterDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftUserToolLanguageFilter) -> UserToolLanguageFilterDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: UserToolLanguageFilterDataModel) -> SwiftUserToolLanguageFilter? {
        return SwiftUserToolLanguageFilter.createNewFrom(model: externalObject)
    }
}
