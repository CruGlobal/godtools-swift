//
//  RealmResourcesCacheSyncResult.swift
//  godtools
//
//  Created by Levi Eggert on 7/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct RealmResourcesCacheSyncResult {
    
    let languagesSyncResult: RealmLanguagesCacheSyncResult
    let resourcesRemoved: [ResourceModel]
    let translationsRemoved: [TranslationModel]
    let attachmentsRemoved: [AttachmentModel]
    let downloadedTranslationsRemoved: [DownloadedTranslationDataModel]
}
