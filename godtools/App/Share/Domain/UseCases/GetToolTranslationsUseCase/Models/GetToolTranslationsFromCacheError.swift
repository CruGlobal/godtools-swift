//
//  GetToolTranslationsFromCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 5/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum GetToolTranslationsFromCacheError: Error {
    
    case failedToFetchTranslationsFromCache(translationIdsNeededDownloading: [String])
}
