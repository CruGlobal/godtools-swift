//
//  ResourcesLatestTranslationServicesError.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesLatestTranslationServicesError: Error {
    case apiError(error: ResponseError<NoClientApiErrorType>)
    case failedToCacheTranslationData(error: Error)
    case failedToGetCachedTranslationData(error: Error)
}
