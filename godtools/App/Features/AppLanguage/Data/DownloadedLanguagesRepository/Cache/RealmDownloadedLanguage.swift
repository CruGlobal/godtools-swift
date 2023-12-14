//
//  RealmDownloadedLanguage.swift
//  godtools
//
//  Created by Rachael Skeath on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDownloadedLanguage: Object {
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var languageId: String = ""
    
    override static func primaryKey() -> String? {
        return "languageId"
    }
    
    func mapFrom(dataModel: DownloadedLanguageDataModel) {
        
        createdAt = dataModel.createdAt
        languageId = dataModel.languageId
    }
}
