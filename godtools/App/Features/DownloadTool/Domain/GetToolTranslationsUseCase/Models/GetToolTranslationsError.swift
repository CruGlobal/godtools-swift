//
//  GetToolTranslationsError.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum GetToolTranslationsError: Error {
    
    case failedToFetchResourceFromCache
    case failedToFetchLanguageFromCache
    case failedToDownloadTranslations(translationDownloaderErrors: [TranslationDownloaderError])
    case failedToFetchPrimaryTranslationManifest
}
