//
//  RealmDownloadedTranslationDataModelMapping.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class RealmDownloadedTranslationDataModelMapping: RepositorySyncMapping {
    
    func toDataModel(externalObject: DownloadedTranslationDataModel) -> DownloadedTranslationDataModel? {
        return DownloadedTranslationDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmDownloadedTranslation) -> DownloadedTranslationDataModel? {
        return DownloadedTranslationDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: DownloadedTranslationDataModel) -> RealmDownloadedTranslation? {
        return RealmDownloadedTranslation.createNewFrom(interface: externalObject)
    }
}
