//
//  DownloadToolErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class DownloadToolErrorViewModel: AlertMessageViewModelType {
    
    let title: String?
    let message: String?
    let cancelTitle: String? = nil
    let acceptTitle: String
    
    required init(downloadToolError: GetToolTranslationsError, localizationServices: LocalizationServices) {
        
        self.acceptTitle = localizationServices.stringForMainBundle(key: "OK")
        
        let internalErrorTitle: String = "Internal Error"
        
        switch downloadToolError {
            
        case .failedToFetchResourceFromCache:
            title = internalErrorTitle
            message = "Failed to fetch resource from cache."
        
        case .failedToFetchLanguageFromCache:
            title = internalErrorTitle
            message = "Failed to fetch language from cache."
        
        case .failedToDownloadTranslations(let translationDownloaderErrors):
            
            guard let translationDownloaderError = translationDownloaderErrors.first else {
                
                title = internalErrorTitle
                message = "Failed to download translations, but unknown reason."
                return
            }
            
            switch translationDownloaderError {
                
            case .failedToCacheTranslation(let error):
                
                title = internalErrorTitle
                
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
                title = internalErrorTitle
                message = "Failed downloading translation because attempted to download a translationId that was an empty string."

            case .noTranslationZipData(let missingTranslationZipData):
                 title = internalErrorTitle
                 message = "Missing translation data for translationId: \(missingTranslationZipData.translationId)"
            }
            
        case .failedToFetchPrimaryTranslationManifest:
            
            title = internalErrorTitle
            message = "Failed to fetch primary translation manifest for tool."
        }
    }
    
    func acceptTapped() {
        // Nothing to implement here, needed for protocol requirement.
    }
}
