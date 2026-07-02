//
//  RealmToolDownload.swift
//  godtools
//
//  Created by Levi Eggert on 6/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmToolDownload: Object, IdentifiableRealmObject {

    @Persisted var id: String = ""
    @Persisted var toolId: String = ""
    @Persisted var languages = List<BCP47LanguageIdentifier>()
    @Persisted var downloadStarted: Date = Date()
    @Persisted var progress: Double = 0
    @Persisted var downloadErrorDescription: String?
    @Persisted var downloadErrorHttpStatusCode: Int?

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmToolDownload {

    func mapFrom(model: ToolDownloadDataModel) {
        id = model.id.value
        toolId = model.toolId
        languages.removeAll()
        languages.append(objectsIn: model.languages)
        downloadStarted = model.downloadStarted
        progress = model.progress
        downloadErrorDescription = model.downloadErrorDescription
        downloadErrorHttpStatusCode = model.downloadErrorHttpStatusCode
    }

    static func createNewFrom(model: ToolDownloadDataModel) -> RealmToolDownload {
        let object = RealmToolDownload()
        object.mapFrom(model: model)
        return object
    }

    func toModel() -> ToolDownloadDataModel {
        return ToolDownloadDataModel(
            toolId: toolId,
            languages: getLanguages(),
            downloadStarted: downloadStarted,
            progress: progress,
            downloadErrorDescription: downloadErrorDescription,
            downloadErrorHttpStatusCode: downloadErrorHttpStatusCode
        )
    }

    func getLanguages() -> [BCP47LanguageIdentifier] {
        return Array(languages)
    }
}
