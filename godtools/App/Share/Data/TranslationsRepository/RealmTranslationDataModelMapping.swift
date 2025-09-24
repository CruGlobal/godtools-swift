//
//  RealmTranslationDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class RealmTranslationDataModelMapping: RepositorySyncMapping {
    
    func toDataModel(externalObject: TranslationCodable) -> TranslationDataModel? {
        return TranslationDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmTranslation) -> TranslationDataModel? {
        return TranslationDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: TranslationCodable) -> RealmTranslation? {
        return RealmTranslation.createNewFrom(interface: externalObject)
    }
}
