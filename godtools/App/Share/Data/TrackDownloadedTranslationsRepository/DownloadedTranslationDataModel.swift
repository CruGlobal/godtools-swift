//
//  DownloadedTranslationDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct DownloadedTranslationDataModel: DownloadedTranslationDataModelType {
    
    let manifestAndRelatedFilesPersistedToDevice: Bool
    let translationId: String
    
    init(model: DownloadedTranslationDataModelType) {
        
        manifestAndRelatedFilesPersistedToDevice = model.manifestAndRelatedFilesPersistedToDevice
        translationId = model.translationId
    }
}
