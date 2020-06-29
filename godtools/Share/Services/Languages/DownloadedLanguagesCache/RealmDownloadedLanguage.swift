//
//  RealmDownloadedLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDownloadedLanguage: Object, DownloadedLanguageModelType {
    
    @objc dynamic var languageId: String = ""
    
    override static func primaryKey() -> String? {
        return "languageId"
    }
}

