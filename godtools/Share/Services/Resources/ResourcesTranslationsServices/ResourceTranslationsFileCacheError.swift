//
//  ResourceTranslationsFileCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourceTranslationsFileCacheError: Error {
    
    case cacheError(error: Error)
    case sha256FileCacheError(error: Error)
    case translationDoesNotExistInCache
}
