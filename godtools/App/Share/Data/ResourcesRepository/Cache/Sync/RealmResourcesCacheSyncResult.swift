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
    let resourceIdsRemoved: [String]
    let translationIdsRemoved: [String]
    let attachmentIdsRemoved: [String]
    let latestAttachmentFiles: [AttachmentFile]
}
