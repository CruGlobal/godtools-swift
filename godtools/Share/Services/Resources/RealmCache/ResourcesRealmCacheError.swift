//
//  ResourcesRealmCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesRealmCacheError: Error {
    
    case failedToDecodeLanguages(error: Error)
    case failedToDecodeResources(error: Error)
    case failedToDecodeTranslations(error: Error)
    case failedToDecodeAttachments(error: Error)
    case failedToCacheToRealm(error: Error)
}
