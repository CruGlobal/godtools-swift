//
//  DownloadToolError.swift
//  godtools
//
//  Created by Levi Eggert on 1/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum DownloadToolError: Error {
    
    case failedToDetermineToolTranslationsToDownload(determineToolTranslationsToDownloadError: DetermineToolTranslationsToDownloadError)
    case failedToDownloadTranslations(translationDownloaderErrors: [TranslationDownloaderError])
    case failedToFetchPrimaryTranslationManifest
}
