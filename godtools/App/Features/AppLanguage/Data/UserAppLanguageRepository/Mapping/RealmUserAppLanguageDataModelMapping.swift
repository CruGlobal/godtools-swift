//
//  RealmUserAppLanguageDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserAppLanguageDataModelMapping: Mapping {
    
    func toDataModel(externalObject: UserAppLanguageDataModel) -> UserAppLanguageDataModel? {
        return UserAppLanguageDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmUserAppLanguage) -> UserAppLanguageDataModel? {
        return UserAppLanguageDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: UserAppLanguageDataModel) -> RealmUserAppLanguage? {
        return RealmUserAppLanguage.createNewFrom(interface: externalObject)
    }
}
