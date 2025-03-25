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
    let downloadProgress: Double
    let downloadStartedAt: Date
    
    init(languageId: String, downloadProgress: Double, downloadStartedAt: Date) {
        
        self.languageId = languageId
        self.downloadProgress = downloadProgress
        self.downloadStartedAt = downloadStartedAt
    }
    
    init(realmToolLanguageDownload: RealmToolLanguageDownload) {
        
        languageId = realmToolLanguageDownload.languageId
        downloadProgress = realmToolLanguageDownload.downloadProgress
        downloadStartedAt = realmToolLanguageDownload.downloadStartedAt
    }
    
    var secondsSinceDownloadStartedAt: TimeInterval? {
        
        return Date().timeIntervalSince(downloadStartedAt)
    }
}
