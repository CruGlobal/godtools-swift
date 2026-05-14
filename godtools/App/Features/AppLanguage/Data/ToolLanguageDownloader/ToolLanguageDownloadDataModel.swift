//
//  ToolLanguageDownloadDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ToolLanguageDownloadDataModel: Sendable {
    
    let id: String
    let languageId: String
    let downloadErrorDescription: String?
    let downloadErrorHttpStatusCode: Int?
    let downloadProgress: Double
    let downloadStartedAt: Date
    
    var secondsSinceDownloadStartedAt: TimeInterval? {
        return Date().timeIntervalSince(downloadStartedAt)
    }
    
    func copy(downloadProgress: Double? = nil, downloadErrorDescription: String? = nil, downloadErrorHttpStatusCode: Int? = nil) -> ToolLanguageDownloadDataModel {
        
        return ToolLanguageDownloadDataModel(
            id: id,
            languageId: languageId,
            downloadErrorDescription: downloadErrorDescription ?? self.downloadErrorDescription,
            downloadErrorHttpStatusCode: downloadErrorHttpStatusCode ?? self.downloadErrorHttpStatusCode,
            downloadProgress: downloadProgress ?? self.downloadProgress,
            downloadStartedAt: downloadStartedAt
        )
    }
}
