//
//  LanguagesDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LanguagesDataModelMapping: RepositorySyncMapping<LanguageDataModel, LanguageCodable, RealmLanguage> {
    
    override func toDataModel(externalObject: LanguageCodable) -> LanguageDataModel? {
        return LanguageDataModel(interface: externalObject)
    }
    
    override func toDataModel(persistObject: RealmLanguage) -> LanguageDataModel? {
        return LanguageDataModel(interface: persistObject)
    }
    
    override func toPersistObject(externalObject: LanguageCodable) -> RealmLanguage? {
        return RealmLanguage.from(interface: externalObject)
    }
}
