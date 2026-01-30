//
//  SwiftTranslationDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftTranslationDataModelMapping: Mapping {
    
    func toDataModel(externalObject: TranslationCodable) -> TranslationDataModel? {
        return TranslationDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftTranslation) -> TranslationDataModel? {
        return TranslationDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: TranslationCodable) -> SwiftTranslation? {
        return SwiftTranslation.createNewFrom(interface: externalObject)
    }
}
