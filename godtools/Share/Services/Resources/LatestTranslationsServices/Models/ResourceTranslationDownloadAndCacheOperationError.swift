//
//  ResourceTranslationDownloadAndCacheOperationError.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourceTranslationDownloadAndCacheOperationError: Error {
    case cancelled
    case failedToCacheTranslationZipData(error: Error)
    case noNetworkConnection
    case unknownError(error: Error)
}
