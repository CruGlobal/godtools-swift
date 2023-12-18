//
//  DownloadedLanguageDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadedLanguageDataModel {
    
    let createdAt: Date
    let languageId: String
    let downloadProgress: Double
    
    var isDownloaded: Bool {
        return downloadProgress >= 1
    }
    
    init(languageId: String, downloadProgress: Double) {
        
        self.createdAt = Date()
        self.languageId = languageId
        self.downloadProgress = downloadProgress
    }
    
    init(realmDownloadedLanguage: RealmDownloadedLanguage) {
        
        createdAt = realmDownloadedLanguage.createdAt
        languageId = realmDownloadedLanguage.languageId
        downloadProgress = realmDownloadedLanguage.downloadProgress
    }
}
