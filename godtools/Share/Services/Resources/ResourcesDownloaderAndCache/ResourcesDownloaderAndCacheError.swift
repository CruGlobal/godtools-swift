//
//  ResourcesDownloadAndCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesDownloaderAndCacheError: Error {
    
    case failedToCacheResources(error: ResourcesCacheError)
    case failedToDecodeLanguages(error: Error)
    case failedToDecodeResourcesPlusLatestTranslationsAndAttachments(error: Error)
    case failedToGetLanguages(error: ResponseError<NoClientApiErrorType>)
    case failedToGetResourcesPlusLatestTranslationsAndAttachments(error: ResponseError<NoClientApiErrorType>)
    case internalErrorFailedToGetLanguagesResult
    case internalErrorFailedToGetResourcesResult
    case internalErrorNoLanguages
    case internalErrorNoResourcesPlusLatestTranslationsAndAttachments
}
