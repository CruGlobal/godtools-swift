//
//  SwiftToolLanguageDownload.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftToolLanguageDownload = SwiftToolLanguageDownloadV1.SwiftToolLanguageDownload

@available(iOS 17.4, *)
enum SwiftToolLanguageDownloadV1 {
 
    @Model
    class SwiftToolLanguageDownload: IdentifiableSwiftDataObject {
        
        var languageId: String = ""
        var downloadErrorDescription: String?
        var downloadErrorHttpStatusCode: Int?
        var downloadProgress: Double = 0
        var downloadStartedAt: Date = Date()
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftToolLanguageDownload {
    
    func mapFrom(model: ToolLanguageDownloadDataModel) {

        id = model.id
        languageId = model.languageId
        downloadErrorDescription = model.downloadErrorDescription
        downloadErrorHttpStatusCode = model.downloadErrorHttpStatusCode
        downloadProgress = model.downloadProgress
        downloadStartedAt = model.downloadStartedAt
    }
    
    static func createNewFrom(model: ToolLanguageDownloadDataModel) -> SwiftToolLanguageDownload {
        let object = SwiftToolLanguageDownload()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ToolLanguageDownloadDataModel {
        return ToolLanguageDownloadDataModel(
            id: id,
            languageId: languageId,
            downloadErrorDescription: downloadErrorDescription,
            downloadErrorHttpStatusCode: downloadErrorHttpStatusCode,
            downloadProgress: downloadProgress,
            downloadStartedAt: downloadStartedAt
        )
    }
}
