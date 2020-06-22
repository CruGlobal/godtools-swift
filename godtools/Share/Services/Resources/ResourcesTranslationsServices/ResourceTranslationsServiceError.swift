//
//  ResourceTranslationsServiceError.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourceTranslationsServiceError: Error {
    
    case failedToCacheTranslations(cacheErrors: [ResourceTranslationsFileCacheError])
    case failedToDownloadTranslations(downloadErrors: [ResponseError<NoClientApiErrorType>])
    case noTranslationZipData(missingTranslationZipData: [NoTranslationZipData])
}
