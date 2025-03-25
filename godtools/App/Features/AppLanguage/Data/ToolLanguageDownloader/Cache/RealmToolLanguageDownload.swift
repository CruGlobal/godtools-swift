//
//  RealmToolLanguageDownload.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmToolLanguageDownload: Object {
    
    @objc dynamic var languageId: String = ""
    @objc dynamic var downloadProgress: Double = 0
    @objc dynamic var downloadStartedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "languageId"
    }
    
    func mapFrom(dataModel: ToolLanguageDownload) {
        
        languageId = dataModel.languageId
        downloadProgress = dataModel.downloadProgress
        downloadStartedAt = dataModel.downloadStartedAt
    }
}
