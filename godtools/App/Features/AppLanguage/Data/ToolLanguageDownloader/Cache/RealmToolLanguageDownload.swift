//
//  RealmToolLanguageDownload.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmToolLanguageDownload: Object, IdentifiableRealmObject {

    @Persisted var id: String = ""
    @Persisted var languageId: String = ""
    @Persisted var downloadErrorDescription: String?
    @Persisted var downloadErrorHttpStatusCode: Int?
    @Persisted var downloadProgress: Double = 0
    @Persisted var downloadStartedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmToolLanguageDownload {
    
    func mapFrom(model: ToolLanguageDownloadDataModel) {

        id = model.id
        languageId = model.languageId
        downloadErrorDescription = model.downloadErrorDescription
        downloadErrorHttpStatusCode = model.downloadErrorHttpStatusCode
        downloadProgress = model.downloadProgress
        downloadStartedAt = model.downloadStartedAt
    }
    
    static func createNewFrom(model: ToolLanguageDownloadDataModel) -> RealmToolLanguageDownload {
        let object = RealmToolLanguageDownload()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ToolLanguageDownloadDataModel {
        return ToolLanguageDownloadDataModel(
            id: id,
            languageId: languageId,
            downloadErrorDescription: downloadErrorDescription,
            downloadErrorHttpStatusCode: downloadErrorHttpStatusCode,
            downloadProgress: downloadProgress,
            downloadStartedAt: downloadStartedAt
        )
    }
}
