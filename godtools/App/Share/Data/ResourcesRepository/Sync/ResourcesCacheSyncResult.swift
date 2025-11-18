//
//  ResourcesCacheSyncResult.swift
//  godtools
//
//  Created by Levi Eggert on 7/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ResourcesCacheSyncResult {
    
    let resourcesRemoved: [ResourceDataModel]
    let translationsRemoved: [TranslationDataModel]
    let attachmentsRemoved: [AttachmentDataModel]
    let downloadedTranslationsRemoved: [DownloadedTranslationDataModel]
}

extension ResourcesCacheSyncResult {
    
    static func emptyResult() -> ResourcesCacheSyncResult {
        return ResourcesCacheSyncResult(
            resourcesRemoved: [],
            translationsRemoved: [],
            attachmentsRemoved: [],
            downloadedTranslationsRemoved: []
        )
    }
}
