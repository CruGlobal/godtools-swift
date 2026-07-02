//
//  SwiftCompletedTrainingTipMapping.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftCompletedTrainingTipMapping: Mapping {
    
    func toDataModel(externalObject: CompletedTrainingTipDataModel) -> CompletedTrainingTipDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: SwiftCompletedTrainingTip) -> CompletedTrainingTipDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: CompletedTrainingTipDataModel) -> SwiftCompletedTrainingTip? {
        return SwiftCompletedTrainingTip.createNewFrom(model: externalObject)
    }
}
