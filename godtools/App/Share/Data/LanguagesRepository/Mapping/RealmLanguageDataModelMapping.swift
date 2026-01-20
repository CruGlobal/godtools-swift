//
//  RealmLanguageDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class RealmLanguageDataModelMapping: GTRepositorySyncMapping {
    
    func toDataModel(externalObject: LanguageCodable) -> LanguageDataModel? {
        return LanguageDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmLanguage) -> LanguageDataModel? {
        return LanguageDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: LanguageCodable) -> RealmLanguage? {
        return RealmLanguage.createNewFrom(interface: externalObject)
    }
}
