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
    
    @objc dynamic var manifestAndRelatedFilesPersistedToDevice: Bool = false
    @objc dynamic var translationId: String = ""
    
    override static func primaryKey() -> String? {
        return "translationId"
    }
    
    func mapFrom(model: DownloadedTranslationDataModel) {
        
        manifestAndRelatedFilesPersistedToDevice = model.manifestAndRelatedFilesPersistedToDevice
        translationId = model.translationId
    }
}
