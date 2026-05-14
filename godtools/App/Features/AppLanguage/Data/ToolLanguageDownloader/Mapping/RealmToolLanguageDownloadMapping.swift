//
//  RealmToolLanguageDownloadMapping.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmToolLanguageDownloadMapping: Mapping {
    
    func toDataModel(externalObject: ToolLanguageDownloadDataModel) -> ToolLanguageDownloadDataModel? {
        return externalObject
    }
    
    func toDataModel(persistObject: RealmToolLanguageDownload) -> ToolLanguageDownloadDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: ToolLanguageDownloadDataModel) -> RealmToolLanguageDownload? {
        return RealmToolLanguageDownload.createNewFrom(model: externalObject)
    }
}
