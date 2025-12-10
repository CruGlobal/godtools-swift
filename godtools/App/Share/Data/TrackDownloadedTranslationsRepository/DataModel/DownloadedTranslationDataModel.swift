//
//  DownloadedTranslationDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct DownloadedTranslationDataModel: DownloadedTranslationDataModelInterface {
    
    let id: String
    let languageId: String
    let manifestAndRelatedFilesPersistedToDevice: Bool
    let resourceId: String
    let translationId: String
    let version: Int
    
    init(id: String, languageId: String, manifestAndRelatedFilesPersistedToDevice: Bool, resourceId: String, translationId: String, version: Int) {
        
        self.id = id
        self.languageId = languageId
        self.manifestAndRelatedFilesPersistedToDevice = manifestAndRelatedFilesPersistedToDevice
        self.resourceId = resourceId
        self.translationId = translationId
        self.version = version
    }
    
    init(interface: DownloadedTranslationDataModelInterface) {
        
        id = interface.id
        languageId = interface.languageId
        manifestAndRelatedFilesPersistedToDevice = interface.manifestAndRelatedFilesPersistedToDevice
        resourceId = interface.resourceId
        translationId = interface.translationId
        version = interface.version
    }
}
