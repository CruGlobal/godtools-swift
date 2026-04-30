//
//  RealmDownloadedLanguageMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmDownloadedLanguageMapping: Mapping {
    
    func toDataModel(externalObject: DownloadedLanguageDataModel) -> DownloadedLanguageDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmDownloadedLanguage) -> DownloadedLanguageDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: DownloadedLanguageDataModel) -> RealmDownloadedLanguage? {
        return RealmDownloadedLanguage.createNewFrom(model: externalObject)
    }
}
