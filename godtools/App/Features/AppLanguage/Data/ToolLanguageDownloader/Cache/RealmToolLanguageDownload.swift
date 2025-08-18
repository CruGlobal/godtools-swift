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
    @objc dynamic var downloadErrorDescription: String?
    @objc dynamic var downloadErrorHttpStatusCode: Int = -1
    @objc dynamic var downloadProgress: Double = 0
    @objc dynamic var downloadStartedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "languageId"
    }
    
    func mapFrom(dataModel: ToolLanguageDownload) {
        
        languageId = dataModel.languageId
        downloadErrorDescription = dataModel.downloadErrorDescription
        downloadErrorHttpStatusCode = dataModel.downloadErrorHttpStatusCode
        downloadProgress = dataModel.downloadProgress
        downloadStartedAt = dataModel.downloadStartedAt
    }
}
