//
//  TranslationZipFileModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TranslationZipFileModel {
    
    let translationId: String
    let resourceId: String
    let languageId: String
    let languageCode: String // bcp47 language tag
    let translationManifestFilename: String
    let translationsVersion: Int
        
    init(realmTranslationZipFile: RealmTranslationZipFile) {
        
        translationId = realmTranslationZipFile.translationId
        resourceId = realmTranslationZipFile.resourceId
        languageId = realmTranslationZipFile.languageId
        languageCode = realmTranslationZipFile.languageCode
        translationManifestFilename = realmTranslationZipFile.translationManifestFilename
        translationsVersion = realmTranslationZipFile.translationsVersion
    }
}
