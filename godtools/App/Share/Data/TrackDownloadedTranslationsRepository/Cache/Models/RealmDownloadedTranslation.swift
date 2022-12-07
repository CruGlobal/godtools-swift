//
//  RealmDownloadedTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDownloadedTranslation: Object, DownloadedTranslationDataModelType {
    
    @objc dynamic var languageId: String = ""
    @objc dynamic var manifestAndRelatedFilesPersistedToDevice: Bool = false
    @objc dynamic var resourceId: String = ""
    @objc dynamic var translationId: String = ""
    @objc dynamic var version: Int = -1
    
    override static func primaryKey() -> String? {
        return "translationId"
    }
    
    func mapFrom(model: DownloadedTranslationDataModel) {
        
        languageId = model.languageId
        manifestAndRelatedFilesPersistedToDevice = model.manifestAndRelatedFilesPersistedToDevice
        resourceId = model.resourceId
        translationId = model.translationId
        version = model.version
    }
}
