//
//  ResourceTranslationDownloadAndCacheOperationResult.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourceTranslationDownloadAndCacheOperationResult {
    
    let resource: GodToolsResource
    let translationZipData: Data
    let cacheLocation: ResourcesLatestTranslationsFileCacheLocation
}
