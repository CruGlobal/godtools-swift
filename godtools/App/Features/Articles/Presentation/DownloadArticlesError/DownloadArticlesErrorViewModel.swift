//
//  DownloadArticlesErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DownloadArticlesErrorViewModel {
    
    let message: String
    
    init(appLanguage: AppLanguageDomainModel, localizationServices: LocalizationServices, error: ArticleAemDownloaderError) {
            
        let notConnectedToNetworkMessage: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.noInternet.key)
        let cancelledError: String = "The request was cancelled"
        let unknownError: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.downloadError.key)
                
        switch error {
        
        case .cancelled:
            message = cancelledError
            
        case .noNetworkConnection:
            message = notConnectedToNetworkMessage
            
        case .unknownError:
            message = unknownError
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
