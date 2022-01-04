//
//  ResourcesDownloaderError.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

enum ResourcesDownloaderError: Error {
    
    case failedToDecodeLanguages(error: Error)
    case failedToDecodeResourcesPlusLatestTranslationsAndAttachments(error: Error)
    case failedToGetLanguages(error: RequestResponseError<NoHttpClientErrorResponse>)
    case failedToGetResourcesPlusLatestTranslationsAndAttachments(error: RequestResponseError<NoHttpClientErrorResponse>)
    case internalErrorFailedToGetLanguagesResult
    case internalErrorFailedToGetResourcesResult
    case internalErrorNoLanguages
    case internalErrorNoResourcesPlusLatestTranslationsAndAttachments
}
