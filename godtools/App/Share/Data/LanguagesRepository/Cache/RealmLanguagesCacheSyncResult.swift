//
//  RealmLanguagesCacheSyncResult.swift
//  godtools
//
//  Created by Levi Eggert on 7/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct RealmLanguagesCacheSyncResult {
    
    typealias LanguageId = String
    
    let languagesStored: [LanguageId: RealmLanguage]
    let languageIdsRemoved: [LanguageId]
}
