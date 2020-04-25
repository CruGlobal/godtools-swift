//
//  GodToolsResource.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct GodToolsResource {
        
    let resourceId: String
    let languageCode: String // bcp47 language tag
    let translationId: String
    let translationManifestFilename: String
    
    init(resource: DownloadedResource, language: Language, translation: Translation) {
        resourceId = resource.remoteId
        languageCode = language.code
        translationId = translation.remoteId
        translationManifestFilename = translation.manifestFilename ?? ""
    }
}
