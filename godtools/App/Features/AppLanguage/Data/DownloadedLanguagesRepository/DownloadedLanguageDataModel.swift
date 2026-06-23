//
//  DownloadedLanguageDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadedLanguageDataModel: Sendable {
    
    let id: String
    let languageId: String
    let downloadComplete: Bool
    let createdAt: Date
    
    init(languageId: String, downloadComplete: Bool, createdAt: Date) {
        
        self.id = languageId
        self.languageId = languageId
        self.downloadComplete = downloadComplete
        self.createdAt = createdAt
    }
    
    func copy(downloadComplete: Bool? = nil, createdAt: Date? = nil) -> DownloadedLanguageDataModel {
        
        return DownloadedLanguageDataModel(
            languageId: languageId,
            downloadComplete: downloadComplete ?? self.downloadComplete,
            createdAt: createdAt ?? self.createdAt,
        )
    }
}
