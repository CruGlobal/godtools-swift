//
//  DetermineToolTranslationsToDownloadError.swift
//  godtools
//
//  Created by Levi Eggert on 1/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum DetermineToolTranslationsToDownloadError: Error {
    
    case failedToFetchResourceFromCache
    case failedToFetchLanguageFromCache
}
