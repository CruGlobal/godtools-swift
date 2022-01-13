//
//  TranslationDownloaderErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class TranslationDownloaderErrorViewModel: AlertMessageType {
    
    let title: String
    let message: String
    
    required init(localizationServices: LocalizationServices, translationDownloaderError: TranslationDownloaderError) {
        
        switch translationDownloaderError {
            
        case .failedToCacheTranslation(let error):
            
            title = "Internal Error"
            
            switch error {
                
            case .cacheError(let error):
                message = "Cache error.  Localized: \(error.localizedDescription)"
            case .getManifestDataError(let error):
                message = "Get manifest data error.  Localized: \(error.localizedDescription)"
            case .sha256FileCacheError(let error):
                message = "SHA256 file cache error.  Localized: \(error.localizedDescription)"
            case .translationDoesNotExistInCache:
                message = "Translation does not exist in cache."
            case .translationManifestDoesNotExistInFileCache:
                message = "Translation manifest does not exist in file cache."
            }
        
        case .failedToDownloadTranslation(let responseError):
            let responseAlert = ResponseErrorAlertMessage(localizationServices: localizationServices, error: responseError)
            title = responseAlert.title
            message = responseAlert.message
            
        case .internalErrorTriedDownloadingAnEmptyTranslationId:
            title = "Internal Error"
            message = "Failed downloading translation because attempted to download a translationId that was an empty string."

        case .noTranslationZipData(let missingTranslationZipData):
             title = "Internal Error"
             message = "Missing translation data for translationId: \(missingTranslationZipData.translationId)"
        }
    }
}
