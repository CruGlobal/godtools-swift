//
//  SwiftPersonalizedToolsMapping.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftPersonalizedToolsMapping: Mapping {

    func toDataModel(externalObject: PersonalizedToolsDataModel) -> PersonalizedToolsDataModel? {
        return externalObject
    }

    func toDataModel(persistObject: SwiftPersonalizedTools) -> PersonalizedToolsDataModel? {
        return persistObject.toModel()
    }

    func toPersistObject(externalObject: PersonalizedToolsDataModel) -> SwiftPersonalizedTools? {
        return SwiftPersonalizedTools.createNewFrom(model: externalObject)
    }
}
