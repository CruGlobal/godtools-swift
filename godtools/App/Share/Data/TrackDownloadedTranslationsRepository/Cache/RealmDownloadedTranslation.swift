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

class RealmDownloadedTranslation: Object, IdentifiableRealmObject, DownloadedTranslationDataModelInterface {
    
    @objc dynamic var id: String = ""
    @objc dynamic var languageId: String = ""
    @objc dynamic var manifestAndRelatedFilesPersistedToDevice: Bool = false
    @objc dynamic var resourceId: String = ""
    @objc dynamic var translationId: String = ""
    @objc dynamic var version: Int = -1
    
    override static func primaryKey() -> String? {
        return "translationId"
    }
    
    func mapFrom(interface: DownloadedTranslationDataModelInterface) {
        id = interface.id
        languageId = interface.languageId
        manifestAndRelatedFilesPersistedToDevice = interface.manifestAndRelatedFilesPersistedToDevice
        resourceId = interface.resourceId
        translationId = interface.translationId
        version = interface.version
    }
    
    static func createNewFrom(interface: DownloadedTranslationDataModelInterface) -> RealmDownloadedTranslation {
        let downloadedTranslation = RealmDownloadedTranslation()
        downloadedTranslation.mapFrom(interface: interface)
        return downloadedTranslation
    }
}
