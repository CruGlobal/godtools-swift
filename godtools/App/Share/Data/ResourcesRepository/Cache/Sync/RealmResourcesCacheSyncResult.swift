//
//  RealmResourcesCacheSyncResult.swift
//  godtools
//
//  Created by Levi Eggert on 7/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct RealmResourcesCacheSyncResult {
    
    let resourcesRemoved: [ResourceDataModel]
    let translationsRemoved: [TranslationDataModel]
    let attachmentsRemoved: [AttachmentDataModel]
    let downloadedTranslationsRemoved: [DownloadedTranslationDataModel]
}

extension RealmResourcesCacheSyncResult {
    
    static func emptyResult() -> RealmResourcesCacheSyncResult {
        return RealmResourcesCacheSyncResult(
            resourcesRemoved: [],
            translationsRemoved: [],
            attachmentsRemoved: [],
            downloadedTranslationsRemoved: []
        )
    }
}
