//
//  SwiftTranslationMapping.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftTranslationMapping: Mapping {
    
    func toDataModel(externalObject: TranslationCodable) -> TranslationDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftTranslation) -> TranslationDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: TranslationCodable) -> SwiftTranslation? {
        return SwiftTranslation.createNewFrom(model: externalObject.toModel())
    }
}
