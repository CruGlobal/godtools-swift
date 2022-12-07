//
//  DownloadedTranslationDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct DownloadedTranslationDataModel: DownloadedTranslationDataModelType {
    
    let languageId: String
    let manifestAndRelatedFilesPersistedToDevice: Bool
    let resourceId: String
    let translationId: String
    let version: Int
    
    init(model: DownloadedTranslationDataModelType) {
        
        languageId = model.languageId
        manifestAndRelatedFilesPersistedToDevice = model.manifestAndRelatedFilesPersistedToDevice
        resourceId = model.resourceId
        translationId = model.translationId
        version = model.version
    }
}
