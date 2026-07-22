//
//  SwiftDownloadedTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftDownloadedTranslation = SwiftDownloadedTranslationV1.SwiftDownloadedTranslation

@available(iOS 17.4, *)
enum SwiftDownloadedTranslationV1 {
 
    @Model
    class SwiftDownloadedTranslation: IdentifiableSwiftDataObject {
        
        var languageId: String = ""
        var manifestAndRelatedFilesPersistedToDevice: Bool = false
        var resourceId: String = ""
        var translationId: String = ""
        var version: Int = -1
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftDownloadedTranslation {
    
    public static func idPredicate(id: String) -> Predicate<SwiftDownloadedTranslation> {
        return #Predicate<SwiftDownloadedTranslation> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftDownloadedTranslation> {
        return #Predicate<SwiftDownloadedTranslation> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: DownloadedTranslationDataModel) {
        id = model.id
        languageId = model.languageId
        manifestAndRelatedFilesPersistedToDevice = model.manifestAndRelatedFilesPersistedToDevice
        resourceId = model.resourceId
        translationId = model.translationId
        version = model.version
    }
    
    static func createNewFrom(model: DownloadedTranslationDataModel) -> SwiftDownloadedTranslation {
        let downloadedTranslation = SwiftDownloadedTranslation()
        downloadedTranslation.mapFrom(model: model)
        return downloadedTranslation
    }
    
    func toModel() -> DownloadedTranslationDataModel {
        return DownloadedTranslationDataModel(
            id: id,
            languageId: languageId,
            manifestAndRelatedFilesPersistedToDevice: manifestAndRelatedFilesPersistedToDevice,
            resourceId: resourceId,
            translationId: translationId,
            version: version
        )
    }
}
