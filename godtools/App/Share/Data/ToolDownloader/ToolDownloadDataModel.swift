//
//  ToolDownloadDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolDownloadDataModel: Sendable {

    let id: ToolDownloadDataModelId
    let toolId: String
    let languages: [BCP47LanguageIdentifier]
    let downloadStarted: Date
    let progress: Double
    let downloadErrorDescription: String?
    let downloadErrorHttpStatusCode: Int?
    
    init(
        toolId: String,
        languages: [BCP47LanguageIdentifier],
        downloadStarted: Date,
        progress: Double,
        downloadErrorDescription: String?,
        downloadErrorHttpStatusCode: Int?
    ) {
        
        self.id = ToolDownloadDataModelId(toolId: toolId, languages: languages)
        self.toolId = toolId
        self.languages = languages
        self.downloadStarted = downloadStarted
        self.progress = progress
        self.downloadErrorDescription = downloadErrorDescription
        self.downloadErrorHttpStatusCode = downloadErrorHttpStatusCode
    }

    var downloadComplete: Bool {
        return progress >= 1
    }

    func copy(progress: Double? = nil, downloadErrorDescription: String? = nil, downloadErrorHttpStatusCode: Int? = nil) -> ToolDownloadDataModel {

        return ToolDownloadDataModel(
            toolId: toolId,
            languages: languages,
            downloadStarted: downloadStarted,
            progress: progress ?? self.progress,
            downloadErrorDescription: downloadErrorDescription ?? self.downloadErrorDescription,
            downloadErrorHttpStatusCode: downloadErrorHttpStatusCode ?? self.downloadErrorHttpStatusCode
        )
    }
}
