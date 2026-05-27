//
//  SwiftResourceViewMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftResourceViewMapping: Mapping {
    
    func toDataModel(externalObject: ResourceViewDataModel) -> ResourceViewDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftResourceView) -> ResourceViewDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ResourceViewDataModel) -> SwiftResourceView? {
        return SwiftResourceView.createNewFrom(model: externalObject)
    }
}
