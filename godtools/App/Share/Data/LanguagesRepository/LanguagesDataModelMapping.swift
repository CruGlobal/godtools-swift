//
//  LanguagesDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LanguagesDataModelMapping: RepositorySyncMapping<LanguageDataModel, LanguageModel, RealmLanguage> {
    
    override func toDataModel(externalObject: LanguageModel) -> LanguageDataModel? {
        return LanguageDataModel(interface: externalObject)
    }
    
    override func toDataModel(persistObject: RealmLanguage) -> LanguageDataModel? {
        return LanguageDataModel(interface: persistObject)
    }
    
    override func toPersistObject(dataModel: LanguageDataModel) -> RealmLanguage? {
        return RealmLanguage.from(interface: dataModel)
    }
}
