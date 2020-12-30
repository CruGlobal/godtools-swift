//
//  TranslationZipFileModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TranslationZipFileModel: TranslationZipFileModelType {
    
    let translationId: String
    let resourceId: String
    let languageId: String
    let languageCode: String // bcp47 language tag
    let translationManifestFilename: String
    let translationsVersion: Int
    let sha256Files: [SHA256FileModel]
    
    init(realmTranslationZipFile: RealmTranslationZipFile) {
        
        translationId = realmTranslationZipFile.translationId
        resourceId = realmTranslationZipFile.resourceId
        languageId = realmTranslationZipFile.languageId
        languageCode = realmTranslationZipFile.languageCode
        translationManifestFilename = realmTranslationZipFile.translationManifestFilename
        translationsVersion = realmTranslationZipFile.translationsVersion
        sha256Files = Array(realmTranslationZipFile.sha256Files).map({SHA256FileModel(realmSHA256File: $0)})
    }
}
