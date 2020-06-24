//
//  ResourcesDownloaderError.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesDownloaderError: Error {
    
    case failedToCacheResources(error: Error)
    case failedToDecodeLanguages(error: Error)
    case failedToDecodeResourcesPlusLatestTranslationsAndAttachments(error: Error)
    case failedToGetLanguages(error: ResponseError<NoClientApiErrorType>)
    case failedToGetResourcesPlusLatestTranslationsAndAttachments(error: ResponseError<NoClientApiErrorType>)
    case internalErrorFailedToGetLanguagesResult
    case internalErrorFailedToGetResourcesResult
    case internalErrorNoLanguages
    case internalErrorNoResourcesPlusLatestTranslationsAndAttachments
}
