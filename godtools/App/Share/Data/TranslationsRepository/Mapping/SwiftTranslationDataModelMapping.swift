//
//  SwiftTranslationDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

@available(iOS 17, *)
class SwiftTranslationDataModelMapping: RepositorySyncMapping {
    
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
