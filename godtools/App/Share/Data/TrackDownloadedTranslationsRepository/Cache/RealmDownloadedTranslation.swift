//
//  RealmDownloadedTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmDownloadedTranslation: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var languageId: String = ""
    @objc dynamic var manifestAndRelatedFilesPersistedToDevice: Bool = false
    @objc dynamic var resourceId: String = ""
    @objc dynamic var translationId: String = ""
    @objc dynamic var version: Int = -1
    
    override static func primaryKey() -> String? {
        return "translationId"
    }
}

extension RealmDownloadedTranslation {
    
    func mapFrom(model: DownloadedTranslationDataModel) {
        id = model.id
        languageId = model.languageId
        manifestAndRelatedFilesPersistedToDevice = model.manifestAndRelatedFilesPersistedToDevice
        resourceId = model.resourceId
        translationId = model.translationId
        version = model.version
    }
    
    static func createNewFrom(model: DownloadedTranslationDataModel) -> RealmDownloadedTranslation {
        let downloadedTranslation = RealmDownloadedTranslation()
        downloadedTranslation.mapFrom(model: model)
        return downloadedTranslation
    }
    
    func toModel() -> DownloadedTranslationDataModel {
        return DownloadedTranslationDataModel(
            id: id,
            languageId: languageId,
            manifestAndRelatedFilesPersistedToDevice: manifestAndRelatedFilesPersistedToDevice,
            resourceId: resourceId,
            translationId: translationId,
            version: version
        )
    }
}
