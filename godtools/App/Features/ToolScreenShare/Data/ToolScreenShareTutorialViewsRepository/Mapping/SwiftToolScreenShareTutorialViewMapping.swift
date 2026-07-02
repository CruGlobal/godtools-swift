//
//  SwiftToolScreenShareTutorialViewMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftToolScreenShareTutorialViewMapping: Mapping {
    
    func toDataModel(externalObject: ToolScreenShareTutorialViewDataModel) -> ToolScreenShareTutorialViewDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftToolScreenTutorialShareView) -> ToolScreenShareTutorialViewDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ToolScreenShareTutorialViewDataModel) -> SwiftToolScreenTutorialShareView? {
        return SwiftToolScreenTutorialShareView.createNewFrom(model: externalObject)
    }
}
