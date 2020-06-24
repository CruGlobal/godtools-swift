//
//  TranslationDownloaderErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslationDownloaderErrorViewModel: AlertMessageType {
    
    let title: String
    let message: String
    
    required init(translationDownloaderError: TranslationDownloaderError) {
        
        switch translationDownloaderError {
            
        case .failedToCacheTranslation(let error):
            title = "Internal Error"
            message = "Internal error cacheing translation to file cache.  Localized: \(error.localizedDescription)"
        
        case .failedToDownloadTranslation(let responseError):
            let responseAlert = ResponseErrorAlertMessage(error: responseError)
            title = responseAlert.title
            message = responseAlert.message

        case .noTranslationZipData(let missingTranslationZipData):
             title = "Internal Error"
             message = "Missing translation data."
        }
    }
}
