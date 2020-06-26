//
//  DownloadedTranslationResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DownloadedTranslationResult {
    
    let translationId: String
    let result: Result<TranslationManifestData, TranslationDownloaderError>
    
    required init(translationId: String, result: Result<TranslationManifestData, TranslationDownloaderError>) {
        
        self.translationId = translationId
        self.result = result
    }
}
