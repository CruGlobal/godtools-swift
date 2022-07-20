//
//  TranslationsFileCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // This should be removed in place of TranslationsRepository following GT-1448. ~Levi
enum TranslationsFileCacheError: Error {
    
    case cacheError(error: Error)
    case getManifestDataError(error: Error)
    case sha256FileCacheError(error: Error)
    case translationDoesNotExistInCache
    case translationManifestDoesNotExistInFileCache
}
