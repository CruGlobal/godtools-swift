//
//  SwiftDownloadedTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
typealias SwiftDownloadedTranslation = SwiftDownloadedTranslationV1.SwiftDownloadedTranslation

@available(iOS 17.4, *)
enum SwiftDownloadedTranslationV1 {
 
    @Model
    class SwiftDownloadedTranslation: IdentifiableSwiftDataObject, DownloadedTranslationDataModelInterface {
        
        var languageId: String = ""
        var manifestAndRelatedFilesPersistedToDevice: Bool = false
        var resourceId: String = ""
        var version: Int = -1
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var translationId: String = ""
        
        init() {
            
        }
        
        func mapFrom(interface: DownloadedTranslationDataModelInterface) {
            id = interface.id
            languageId = interface.languageId
            manifestAndRelatedFilesPersistedToDevice = interface.manifestAndRelatedFilesPersistedToDevice
            resourceId = interface.resourceId
            translationId = interface.translationId
            version = interface.version
        }
        
        static func createNewFrom(interface: DownloadedTranslationDataModelInterface) -> SwiftDownloadedTranslation {
            let downloadedTranslation = SwiftDownloadedTranslation()
            downloadedTranslation.mapFrom(interface: interface)
            return downloadedTranslation
        }
    }
}
