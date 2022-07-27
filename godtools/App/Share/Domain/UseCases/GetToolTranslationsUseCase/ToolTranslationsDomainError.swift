//
//  ToolTranslationsDomainError.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum ToolTranslationsDomainError: Error {
    
    case errorFetchingTranslationManifestsFromCache(error: Error)
    case errorParsingTranslationManifestData(error: Error)
    case failedToFetchResourcesFromCache
    case failedToFetchTranslationFilesFromCache(translationIds: [String])
}
