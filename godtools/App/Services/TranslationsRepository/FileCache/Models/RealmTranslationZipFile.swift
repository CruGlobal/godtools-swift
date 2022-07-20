//
//  RealmTranslationZipFile.swift
//  godtools
//
//  Created by Levi Eggert on 6/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

// TODO: Remove in GT-1448. ~Levi
class RealmTranslationZipFile: Object, TranslationZipFileModelType {
    
    @objc dynamic var translationId: String = ""
    @objc dynamic var resourceId: String = ""
    @objc dynamic var languageId: String = ""
    @objc dynamic var languageCode: String = "" // bcp47 language tag
    @objc dynamic var translationManifestFilename: String = ""
    @objc dynamic var translationsVersion: Int = -1
    
    let sha256Files = List<RealmSHA256File>()
    
    override static func primaryKey() -> String? {
        return "translationId"
    }
}
