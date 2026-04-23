//
//  RealmLanguageMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmLanguageMapping: Mapping {
    
    func toDataModel(externalObject: LanguageCodable) -> LanguageDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmLanguage) -> LanguageDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: LanguageCodable) -> RealmLanguage? {
        return RealmLanguage.createNewFrom(model: externalObject.toModel())
    }
}
