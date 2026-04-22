//
//  SwiftDownloadedLanguage.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftDownloadedLanguage = SwiftDownloadedLanguageV1.SwiftDownloadedLanguage

@available(iOS 17.4, *)
enum SwiftDownloadedLanguageV1 {
    
    @Model
    class SwiftDownloadedLanguage: IdentifiableSwiftDataObject {
        
        var createdAt: Date = Date()
        var downloadComplete: Bool = false
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var languageId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftDownloadedLanguage {
    
    func mapFrom(model: DownloadedLanguageDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        languageId = model.languageId
        downloadComplete = model.downloadComplete
    }
    
    static func createNewFrom(model: DownloadedLanguageDataModel) -> SwiftDownloadedLanguage {
        
        let object = SwiftDownloadedLanguage()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftDownloadedLanguage {
    
    func toModel() -> DownloadedLanguageDataModel {
        return DownloadedLanguageDataModel(
            id: id,
            createdAt: createdAt,
            languageId: languageId,
            downloadComplete: downloadComplete
        )
    }
}
