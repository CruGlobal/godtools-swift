//
//  SwiftFollowUpMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftFollowUpMapping: Mapping {
    
    func toDataModel(externalObject: FollowUpDataModel) -> FollowUpDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftFollowUp) -> FollowUpDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: FollowUpDataModel) -> SwiftFollowUp? {
        return SwiftFollowUp.createNewFrom(model: externalObject)
    }
}
