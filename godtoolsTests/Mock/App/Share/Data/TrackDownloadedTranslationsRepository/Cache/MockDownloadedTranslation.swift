//
//  MockDownloadedTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockDownloadedTranslation: DownloadedTranslationDataModelInterface {
    
    var id: String = ""
    var languageId: String = ""
    var manifestAndRelatedFilesPersistedToDevice: Bool = false
    var resourceId: String = ""
    var translationId: String = ""
    var version: Int = -1
    
    init(resourceId: String, languageId: String, version: Int, translationId: String? = nil, id: String? = nil, manifestAndRelatedFilesPersistedToDevice: Bool = false) {
        
        let uniqueId: String = UUID().uuidString
        
        self.id = id ?? uniqueId
        self.resourceId = resourceId
        self.languageId = languageId
        self.translationId = translationId ?? uniqueId
        self.version = version
        self.manifestAndRelatedFilesPersistedToDevice = manifestAndRelatedFilesPersistedToDevice
    }
}
