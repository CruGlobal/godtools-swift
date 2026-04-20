//
//  RealmDownloadedTranslationDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmDownloadedTranslationDataModelMapping: Mapping {
    
    func toDataModel(externalObject: DownloadedTranslationDataModel) -> DownloadedTranslationDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmDownloadedTranslation) -> DownloadedTranslationDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: DownloadedTranslationDataModel) -> RealmDownloadedTranslation? {
        return RealmDownloadedTranslation.createNewFrom(model: externalObject)
    }
}
