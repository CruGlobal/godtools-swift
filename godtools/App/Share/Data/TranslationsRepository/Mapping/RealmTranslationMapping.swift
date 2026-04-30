//
//  RealmTranslationMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmTranslationMapping: Mapping {
    
    func toDataModel(externalObject: TranslationCodable) -> TranslationDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmTranslation) -> TranslationDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: TranslationCodable) -> RealmTranslation? {
        return RealmTranslation.createNewFrom(model: externalObject.toModel())
    }
}
