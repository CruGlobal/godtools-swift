//
//  DownloadedTranslationResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// TODO: Remove in GT-1448. ~Levi
class DownloadedTranslationResult {
    
    let translationId: String
    let downloadError: TranslationDownloaderError?
    
    required init(translationId: String, downloadError: TranslationDownloaderError?) {
        
        self.translationId = translationId
        self.downloadError = downloadError
    }
}
