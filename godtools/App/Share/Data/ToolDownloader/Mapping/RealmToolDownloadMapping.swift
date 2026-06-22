//
//  RealmToolDownloadMapping.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmToolDownloadMapping: Mapping {

    func toDataModel(externalObject: ToolDownloadDataModel) -> ToolDownloadDataModel? {
        return externalObject
    }

    func toDataModel(persistObject: RealmToolDownload) -> ToolDownloadDataModel? {
        return persistObject.toModel()
    }

    func toPersistObject(externalObject: ToolDownloadDataModel) -> RealmToolDownload? {
        return RealmToolDownload.createNewFrom(model: externalObject)
    }
}
