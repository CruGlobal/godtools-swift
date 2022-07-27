//
//  GetToolTranslationsManifestsFromCacheResult.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum GetToolTranslationsManifestsFromCacheResult {
    
    case didGetToolTranslationsData(toolTranslationsData: [ToolTranslationData])
    case failedToFetchResourcesFromCache
    case failedToFetchTranslationManifestsFromCache(translationIds: [String])
}
