//
//  ToolLanguageDownload.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ToolLanguageDownload {
    
    let languageId: String
    let downloadErrorDescription: String?
    let downloadErrorHttpStatusCode: Int
    let downloadProgress: Double
    let downloadStartedAt: Date
    
    init(languageId: String, downloadErrorDescription: String?, downloadErrorHttpStatusCode: Int?, downloadProgress: Double, downloadStartedAt: Date) {
        
        self.languageId = languageId
        self.downloadErrorDescription = downloadErrorDescription
        self.downloadErrorHttpStatusCode = downloadErrorHttpStatusCode ?? -1
        self.downloadProgress = downloadProgress
        self.downloadStartedAt = downloadStartedAt
    }
    
    init(realmToolLanguageDownload: RealmToolLanguageDownload) {
        
        languageId = realmToolLanguageDownload.languageId
        downloadErrorDescription = realmToolLanguageDownload.downloadErrorDescription
        downloadErrorHttpStatusCode = realmToolLanguageDownload.downloadErrorHttpStatusCode
        downloadProgress = realmToolLanguageDownload.downloadProgress
        downloadStartedAt = realmToolLanguageDownload.downloadStartedAt
    }
    
    var secondsSinceDownloadStartedAt: TimeInterval? {
        
        return Date().timeIntervalSince(downloadStartedAt)
    }
}
