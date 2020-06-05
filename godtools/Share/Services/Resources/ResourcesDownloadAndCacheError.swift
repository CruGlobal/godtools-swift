//
//  ResourcesDownloadAndCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesDownloadAndCacheError: Error {
    
    case cancelled
    case cacheError(error: ResourcesRealmCacheError)
    case failedToGetLanguages(error: Error, data: Data?)
    case failedToGetResourcesPlusLatestTranslationsAndAttachments(error: Error, data: Data?)
    case internalErrorMissingResponseData
    case noNetworkConnection
    case unknownError(error: Error)
}
