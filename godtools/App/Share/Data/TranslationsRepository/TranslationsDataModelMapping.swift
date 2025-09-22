//
//  TranslationsDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class TranslationsDataModelMapping: RealmRepositorySyncMapping<TranslationDataModel, TranslationCodable, RealmTranslation> {
    
    override func toDataModel(externalObject: TranslationCodable) -> TranslationDataModel? {
        return TranslationDataModel(interface: externalObject)
    }
    
    override func toDataModel(persistObject: RealmTranslation) -> TranslationDataModel? {
        return TranslationDataModel(interface: persistObject)
    }
    
    override func toPersistObject(externalObject: TranslationCodable) -> RealmTranslation? {
        return RealmTranslation.createNewFrom(interface: externalObject)
    }
}
