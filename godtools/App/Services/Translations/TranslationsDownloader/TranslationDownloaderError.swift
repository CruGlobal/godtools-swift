//
//  TranslationDownloaderError.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum TranslationDownloaderError: Error {
    
    case failedToCacheTranslation(error: TranslationsFileCacheError)
    case failedToDownloadTranslation(error: ResponseError<NoClientApiErrorType>)
    case internalErrorTriedDownloadingAnEmptyTranslationId
    case noTranslationZipData(missingTranslationZipData: NoTranslationZipData)
    
    var cancelled: Bool {
        switch self {
        case .failedToDownloadTranslation(let responseError):
            return responseError.cancelled
        default:
            return false
        }
    }
}
