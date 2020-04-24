//
//  ResourcesLatestTranslationsZipFileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourcesLatestTranslationsZipFileCacheLocation: ZipFileContentsCacheLocationType {
        
    let resourceId: String
    let languageCode: String
    let relativeUrl: URL?
    
    init(resource: DownloadedResource, language: Language) {
        
        resourceId = resource.remoteId
        languageCode = language.code
        relativeUrl = URL(string: resourceId)?.appendingPathComponent(languageCode).appendingPathComponent("translation_contents")
    }
}
