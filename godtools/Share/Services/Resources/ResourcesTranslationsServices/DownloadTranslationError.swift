//
//  DownloadTranslationError.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum DownloadTranslationError: Error {
    
    case failedToCacheTranslation(error: ResourceTranslationsFileCacheError)
    case failedToDownloadTranslation(error: ResponseError<NoClientApiErrorType>)
    case noTranslationZipData(missingTranslationZipData: NoTranslationZipData)
}
