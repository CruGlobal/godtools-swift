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
    let languageId: String
    let relativeUrl: URL?
    
    init(resource: DownloadedResource, language: Language) {
        
        self.resourceId = resource.remoteId
        self.languageId = language.remoteId
        self.relativeUrl = URL(string: resourceId)?.appendingPathComponent(languageId).appendingPathComponent("translation_contents")
    }
}
