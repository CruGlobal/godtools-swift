//
//  RealmAppLanguageDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmAppLanguageDataModelMapping: Mapping {
    
    func toDataModel(externalObject: AppLanguageCodable) -> AppLanguageDataModel? {
        return AppLanguageDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmAppLanguage) -> AppLanguageDataModel? {
        return AppLanguageDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: AppLanguageCodable) -> RealmAppLanguage? {
        return RealmAppLanguage.createNewFrom(interface: externalObject)
    }
}
